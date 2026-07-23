import { describe, it, expect, beforeEach } from 'vitest';
import { mockClient } from 'aws-sdk-client-mock';
import {
  RDSDataClient,
  ExecuteStatementCommand,
  ExecuteStatementCommandInput,
  BatchExecuteStatementCommand,
} from '@aws-sdk/client-rds-data';
import type { APIGatewayProxyEventV2, APIGatewayProxyStructuredResultV2 } from 'aws-lambda';

process.env.CLUSTER_ARN = 'arn:aws:rds:us-east-1:123456789012:cluster:test';
process.env.SECRET_ARN = 'arn:aws:secretsmanager:us-east-1:123456789012:secret:test';
process.env.DB_NAME = 'icdb';

const { handler } = await import('../src/comments');

const rdsMock = mockClient(RDSDataClient);

const COMMENT = {
  id: '2f9d1c9a-64b8-4a02-a4b7-0d3c15c3aaaa',
  page: '/cats/maru',
  name: 'Ada',
  comment: 'What a cat!',
  created_at: '2026-07-23 10:00:00',
};

function apiEvent(
  method: string,
  path: string,
  options: { body?: unknown; id?: string; query?: Record<string, string> } = {},
): APIGatewayProxyEventV2 {
  return {
    version: '2.0',
    routeKey: `${method} ${path}`,
    rawPath: path,
    rawQueryString: '',
    headers: {},
    queryStringParameters: options.query,
    pathParameters: options.id ? { id: options.id } : undefined,
    body: options.body === undefined ? undefined : JSON.stringify(options.body),
    isBase64Encoded: false,
    requestContext: { http: { method } },
  } as unknown as APIGatewayProxyEventV2;
}

function records(rows: unknown[]) {
  return { formattedRecords: JSON.stringify(rows) };
}

function statements(): ExecuteStatementCommandInput[] {
  return rdsMock.commandCalls(ExecuteStatementCommand).map((c) => c.args[0].input);
}

function dataStatements(): ExecuteStatementCommandInput[] {
  return statements().filter((s) => !s.sql?.includes('CREATE TABLE'));
}

beforeEach(() => {
  rdsMock.reset();
  rdsMock.on(ExecuteStatementCommand).resolves(records([]));
});

describe('POST /comments', () => {
  it('creates a comment and returns 201', async () => {
    rdsMock
      .on(ExecuteStatementCommand)
      .resolves(records([]))
      .callsFake((input: ExecuteStatementCommandInput) =>
        input.sql?.includes('INSERT INTO comments') ? records([COMMENT]) : records([]),
      );

    const result = (await handler(
      apiEvent('POST', '/comments', {
        body: { page: '/cats/maru', name: 'Ada', comment: 'What a cat!' },
      }),
    )) as APIGatewayProxyStructuredResultV2;

    expect(result.statusCode).toBe(201);
    expect(JSON.parse(result.body!)).toEqual(COMMENT);
    const insert = dataStatements()[0];
    expect(insert.parameters).toEqual([
      { name: 'page', value: { stringValue: '/cats/maru' } },
      { name: 'name', value: { stringValue: 'Ada' } },
      { name: 'comment', value: { stringValue: 'What a cat!' } },
    ]);
  });

  it('rejects a comment with missing fields', async () => {
    const result = (await handler(
      apiEvent('POST', '/comments', { body: { page: '/cats/maru' } }),
    )) as APIGatewayProxyStructuredResultV2;

    expect(result.statusCode).toBe(400);
    expect(dataStatements()).toHaveLength(0);
  });

  it('rejects a non-JSON body', async () => {
    const event = apiEvent('POST', '/comments');
    event.body = 'not json';
    const result = (await handler(event)) as APIGatewayProxyStructuredResultV2;
    expect(result.statusCode).toBe(400);
  });
});

describe('GET /comments', () => {
  it('lists comments', async () => {
    rdsMock.on(ExecuteStatementCommand).callsFake((input: ExecuteStatementCommandInput) =>
      input.sql?.includes('SELECT') ? records([COMMENT]) : records([]),
    );

    const result = (await handler(
      apiEvent('GET', '/comments'),
    )) as APIGatewayProxyStructuredResultV2;

    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body!)).toEqual([COMMENT]);
  });

  it('filters by page when the query parameter is present', async () => {
    const result = (await handler(
      apiEvent('GET', '/comments', { query: { page: '/cats/maru' } }),
    )) as APIGatewayProxyStructuredResultV2;

    expect(result.statusCode).toBe(200);
    const select = dataStatements()[0];
    expect(select.sql).toContain('WHERE page = :page');
    expect(select.parameters).toEqual([
      { name: 'page', value: { stringValue: '/cats/maru' } },
    ]);
  });
});

describe('GET /comments/{id}', () => {
  it('returns a comment by id', async () => {
    rdsMock.on(ExecuteStatementCommand).callsFake((input: ExecuteStatementCommandInput) =>
      input.sql?.includes('SELECT') ? records([COMMENT]) : records([]),
    );

    const result = (await handler(
      apiEvent('GET', '/comments/{id}', { id: COMMENT.id }),
    )) as APIGatewayProxyStructuredResultV2;

    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body!).id).toBe(COMMENT.id);
  });

  it('returns 404 for a missing comment', async () => {
    const result = (await handler(
      apiEvent('GET', '/comments/{id}', { id: COMMENT.id }),
    )) as APIGatewayProxyStructuredResultV2;
    expect(result.statusCode).toBe(404);
  });

  it('rejects a malformed id without querying', async () => {
    const result = (await handler(
      apiEvent('GET', '/comments/{id}', { id: 'nope' }),
    )) as APIGatewayProxyStructuredResultV2;
    expect(result.statusCode).toBe(400);
    expect(dataStatements()).toHaveLength(0);
  });
});

describe('PUT /comments/{id}', () => {
  it('updates a comment', async () => {
    const updated = { ...COMMENT, comment: 'Even better on rewatch' };
    rdsMock.on(ExecuteStatementCommand).callsFake((input: ExecuteStatementCommandInput) =>
      input.sql?.includes('UPDATE comments') ? records([updated]) : records([]),
    );

    const result = (await handler(
      apiEvent('PUT', '/comments/{id}', {
        id: COMMENT.id,
        body: { comment: 'Even better on rewatch' },
      }),
    )) as APIGatewayProxyStructuredResultV2;

    expect(result.statusCode).toBe(200);
    expect(JSON.parse(result.body!).comment).toBe('Even better on rewatch');
    const update = dataStatements()[0];
    expect(update.parameters).toContainEqual({
      name: 'name',
      value: { isNull: true },
    });
  });

  it('requires at least one updatable field', async () => {
    const result = (await handler(
      apiEvent('PUT', '/comments/{id}', { id: COMMENT.id, body: {} }),
    )) as APIGatewayProxyStructuredResultV2;
    expect(result.statusCode).toBe(400);
  });

  it('returns 404 when the comment does not exist', async () => {
    const result = (await handler(
      apiEvent('PUT', '/comments/{id}', { id: COMMENT.id, body: { comment: 'hi' } }),
    )) as APIGatewayProxyStructuredResultV2;
    expect(result.statusCode).toBe(404);
  });
});

describe('DELETE /comments/{id}', () => {
  it('deletes a comment and returns 204', async () => {
    rdsMock.on(ExecuteStatementCommand).callsFake((input: ExecuteStatementCommandInput) =>
      input.sql?.includes('DELETE FROM comments') ? records([{ id: COMMENT.id }]) : records([]),
    );

    const result = (await handler(
      apiEvent('DELETE', '/comments/{id}', { id: COMMENT.id }),
    )) as APIGatewayProxyStructuredResultV2;
    expect(result.statusCode).toBe(204);
  });

  it('returns 404 when already gone', async () => {
    const result = (await handler(
      apiEvent('DELETE', '/comments/{id}', { id: COMMENT.id }),
    )) as APIGatewayProxyStructuredResultV2;
    expect(result.statusCode).toBe(404);
  });
});

describe('GET /init', () => {
  it('seeds comments when the table is empty', async () => {
    rdsMock.on(ExecuteStatementCommand).callsFake((input: ExecuteStatementCommandInput) =>
      input.sql?.includes('count(*)') ? records([{ n: 0 }]) : records([]),
    );
    rdsMock.on(BatchExecuteStatementCommand).resolves({});

    const result = (await handler(
      apiEvent('GET', '/init'),
    )) as APIGatewayProxyStructuredResultV2;

    expect(result.statusCode).toBe(201);
    expect(JSON.parse(result.body!).seeded).toBeGreaterThan(0);
    const batch = rdsMock.commandCalls(BatchExecuteStatementCommand);
    expect(batch).toHaveLength(1);
    const sets = batch[0].args[0].input.parameterSets!;
    expect(sets.length).toBe(JSON.parse(result.body!).seeded);
    expect(sets[0].map((p) => p.name)).toEqual(['page', 'name', 'comment']);
  });

  it('returns an error when comments already exist', async () => {
    rdsMock.on(ExecuteStatementCommand).callsFake((input: ExecuteStatementCommandInput) =>
      input.sql?.includes('count(*)') ? records([{ n: 7 }]) : records([]),
    );

    const result = (await handler(
      apiEvent('GET', '/init'),
    )) as APIGatewayProxyStructuredResultV2;

    expect(result.statusCode).toBe(409);
    expect(JSON.parse(result.body!)).toEqual({ error: 'comments table is not empty' });
    expect(rdsMock.commandCalls(BatchExecuteStatementCommand)).toHaveLength(0);
  });
});

describe('routing', () => {
  it('returns 405 for unsupported methods', async () => {
    const result = (await handler(
      apiEvent('PATCH', '/comments'),
    )) as APIGatewayProxyStructuredResultV2;
    expect(result.statusCode).toBe(405);
  });
});
