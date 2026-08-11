import {
  RDSDataClient,
  ExecuteStatementCommand,
  BatchExecuteStatementCommand,
  SqlParameter,
} from '@aws-sdk/client-rds-data';
import type {
  APIGatewayProxyEventV2,
  APIGatewayProxyResultV2,
} from 'aws-lambda';
import { SEED_COMMENTS } from './seeds';

const client = new RDSDataClient({});

const COMMENT_COLUMNS = 'id, page, name, comment, created_at';

export interface Comment {
  id: string;
  page: string;
  name: string;
  comment: string;
  created_at: string;
}

function param(name: string, value: string): SqlParameter {
  return { name, value: { stringValue: value } };
}

function uuidParam(name: string, value: string): SqlParameter {
  return { name, value: { stringValue: value }, typeHint: 'UUID' };
}

const db = {
  resourceArn: process.env.CLUSTER_ARN,
  secretArn: process.env.SECRET_ARN,
  database: process.env.DB_NAME,
};

// The cluster scales to zero when idle; the first statement after a pause
// fails with DatabaseResumingException until the database is back up.
async function withResumeRetry<T>(send: () => Promise<T>): Promise<T> {
  const deadline = Date.now() + 25_000;
  for (;;) {
    try {
      return await send();
    } catch (err) {
      const resuming =
        err instanceof Error &&
        (err.name === 'DatabaseResumingException' ||
          err.message.includes('resuming'));
      if (!resuming || Date.now() > deadline) throw err;
      await new Promise((r) => setTimeout(r, 2_000));
    }
  }
}

async function sql<T = Comment>(
  statement: string,
  parameters: SqlParameter[] = [],
): Promise<T[]> {
  const result = await withResumeRetry(() =>
    client.send(
      new ExecuteStatementCommand({
        ...db,
        sql: statement,
        parameters,
        formatRecordsAs: 'JSON',
      }),
    ),
  );
  return result.formattedRecords ? JSON.parse(result.formattedRecords) : [];
}

async function initComments(): Promise<APIGatewayProxyResultV2> {
  const [{ n }] = await sql<{ n: number }>(
    'SELECT count(*)::int AS n FROM comments',
  );
  if (n > 0) {
    return response(409, { error: 'comments table is not empty' });
  }
  await withResumeRetry(() =>
    client.send(
      new BatchExecuteStatementCommand({
        ...db,
        sql: `INSERT INTO comments (page, name, comment)
              VALUES (:page, :name, :comment)`,
        parameterSets: SEED_COMMENTS.map((seed) => [
          param('page', seed.page),
          param('name', seed.name),
          param('comment', seed.comment),
        ]),
      }),
    ),
  );
  return response(201, { seeded: SEED_COMMENTS.length });
}

let schemaReady: Promise<Comment[]> | undefined;
function ensureSchema(): Promise<Comment[]> {
  schemaReady ??= sql(`
    CREATE TABLE IF NOT EXISTS comments (
      id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
      page text NOT NULL,
      name text NOT NULL,
      comment text NOT NULL,
      created_at timestamptz NOT NULL DEFAULT now()
    )`);
  return schemaReady;
}

function response(statusCode: number, body?: unknown): APIGatewayProxyResultV2 {
  return {
    statusCode,
    headers: { 'content-type': 'application/json' },
    body: body === undefined ? '' : JSON.stringify(body),
  };
}

function badRequest(message: string): APIGatewayProxyResultV2 {
  return response(400, { error: message });
}

function parseBody(event: APIGatewayProxyEventV2): Record<string, unknown> | undefined {
  if (!event.body) return undefined;
  try {
    const raw = event.isBase64Encoded
      ? Buffer.from(event.body, 'base64').toString('utf-8')
      : event.body;
    const parsed = JSON.parse(raw);
    return typeof parsed === 'object' && parsed !== null ? parsed : undefined;
  } catch {
    return undefined;
  }
}

function asText(value: unknown): string | undefined {
  return typeof value === 'string' && value.trim() !== '' ? value.trim() : undefined;
}

async function createComment(event: APIGatewayProxyEventV2): Promise<APIGatewayProxyResultV2> {
  const body = parseBody(event);
  const page = asText(body?.page);
  const name = asText(body?.name);
  const comment = asText(body?.comment);
  if (!page || !name || !comment) {
    return badRequest('page, name and comment are required');
  }
  const [created] = await sql(
    `INSERT INTO comments (page, name, comment)
     VALUES (:page, :name, :comment)
     RETURNING ${COMMENT_COLUMNS}`,
    [param('page', page), param('name', name), param('comment', comment)],
  );
  return response(201, created);
}

async function listComments(event: APIGatewayProxyEventV2): Promise<APIGatewayProxyResultV2> {
  const page = event.queryStringParameters?.page;
  const rows = page
    ? await sql(
        `SELECT ${COMMENT_COLUMNS} FROM comments
         WHERE page = :page ORDER BY created_at DESC LIMIT 100`,
        [param('page', page)],
      )
    : await sql(
        `SELECT ${COMMENT_COLUMNS} FROM comments
         ORDER BY created_at DESC LIMIT 100`,
      );
  return response(200, rows);
}

async function getComment(id: string): Promise<APIGatewayProxyResultV2> {
  const [row] = await sql(
    `SELECT ${COMMENT_COLUMNS} FROM comments WHERE id = :id`,
    [uuidParam('id', id)],
  );
  return row ? response(200, row) : response(404, { error: 'comment not found' });
}

async function updateComment(
  id: string,
  event: APIGatewayProxyEventV2,
): Promise<APIGatewayProxyResultV2> {
  const body = parseBody(event);
  const name = asText(body?.name);
  const comment = asText(body?.comment);
  if (!name && !comment) {
    return badRequest('name or comment is required');
  }
  const [updated] = await sql(
    `UPDATE comments
     SET name = COALESCE(CAST(:name AS text), name),
         comment = COALESCE(CAST(:comment AS text), comment)
     WHERE id = :id
     RETURNING ${COMMENT_COLUMNS}`,
    [
      name ? param('name', name) : { name: 'name', value: { isNull: true } },
      comment ? param('comment', comment) : { name: 'comment', value: { isNull: true } },
      uuidParam('id', id),
    ],
  );
  return updated ? response(200, updated) : response(404, { error: 'comment not found' });
}

async function deleteComment(id: string): Promise<APIGatewayProxyResultV2> {
  const [deleted] = await sql(
    'DELETE FROM comments WHERE id = :id RETURNING id',
    [uuidParam('id', id)],
  );
  return deleted ? response(204) : response(404, { error: 'comment not found' });
}

export async function handler(
  event: APIGatewayProxyEventV2,
): Promise<APIGatewayProxyResultV2> {
  try {
    // Behind the CDN the function is the default origin; send bare requests
    // for the site root to the app, which lives under /app.
    if (event.rawPath === '/' || event.rawPath === '') {
      return { statusCode: 302, headers: { location: '/app/index.html' } };
    }

    await ensureSchema();
    const method = event.requestContext.http.method;
    const id = event.pathParameters?.id;

    if (id) {
      if (!/^[0-9a-f-]{36}$/i.test(id)) return badRequest('invalid comment id');
      if (method === 'GET') return await getComment(id);
      if (method === 'PUT') return await updateComment(id, event);
      if (method === 'DELETE') return await deleteComment(id);
    } else if (event.rawPath === '/init') {
      if (method === 'GET') return await initComments();
    } else {
      if (method === 'POST') return await createComment(event);
      if (method === 'GET') return await listComments(event);
    }
    return response(405, { error: 'method not allowed' });
  } catch (err) {
    console.error('comments handler failed', err);
    return response(500, { error: 'internal error' });
  }
}
