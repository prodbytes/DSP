import json

# In-memory TODO list; persists only for the lifetime of a warm Lambda container.
TODOS = []


def lambda_handler(event, context):
    """TODO API Lambda function.

    GET  -> returns the list of TODO items
    POST -> adds a TODO item; body is the item string, or JSON {"item": "..."}
    """
    method = event.get("httpMethod", "GET")

    if method == "POST":
        return post_todo(event)
    return get_todos()


def get_todos():
    return _response(200, {"todos": TODOS})


def post_todo(event):
    body = event.get("body") or ""
    try:
        parsed = json.loads(body)
        item = parsed.get("item") if isinstance(parsed, dict) else parsed
    except json.JSONDecodeError:
        item = body

    if not isinstance(item, str) or not item.strip():
        return _response(400, {"error": "TODO item must be a non-empty string"})

    TODOS.append(item.strip())
    return _response(201, {"todos": TODOS})


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }
