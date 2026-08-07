import ast
import json
import operator

MAX_EXPRESSION_LENGTH = 200
MAX_POW_EXPONENT = 64

_OPS = {
    ast.Add: operator.add,
    ast.Sub: operator.sub,
    ast.Mult: operator.mul,
    ast.Div: operator.truediv,
    ast.FloorDiv: operator.floordiv,
    ast.Mod: operator.mod,
    ast.Pow: operator.pow,
    ast.UAdd: operator.pos,
    ast.USub: operator.neg,
}


def _evaluate_node(node):
    if isinstance(node, ast.Expression):
        return _evaluate_node(node.body)
    if isinstance(node, ast.Constant) and type(node.value) in (int, float):
        return node.value
    if isinstance(node, ast.BinOp) and type(node.op) in _OPS:
        left, right = _evaluate_node(node.left), _evaluate_node(node.right)
        if isinstance(node.op, ast.Pow) and abs(right) > MAX_POW_EXPONENT:
            raise ValueError(f"exponent too large (max {MAX_POW_EXPONENT})")
        return _OPS[type(node.op)](left, right)
    if isinstance(node, ast.UnaryOp) and type(node.op) in _OPS:
        return _OPS[type(node.op)](_evaluate_node(node.operand))
    raise ValueError(f"unsupported syntax: {type(node).__name__}")


def evaluate_expression(expression):
    """Safely evaluate an arithmetic expression like "2 + 3".

    Only numeric literals, + - * / // % ** and parentheses are allowed;
    names, calls, and any other Python syntax are rejected.
    """
    if len(expression) > MAX_EXPRESSION_LENGTH:
        raise ValueError(f"expression too long (max {MAX_EXPRESSION_LENGTH} characters)")
    try:
        tree = ast.parse(expression, mode="eval")
    except SyntaxError as e:
        raise ValueError(f"invalid expression: {e.msg}") from e
    return _evaluate_node(tree)


def _extract_expression(event):
    """Pull the expression from the `expr` query parameter or the request body.

    The body may be a raw expression string or JSON like {"expression": "2 + 3"}.
    """
    params = event.get("queryStringParameters") or {}
    body = event.get("body") or ""
    try:
        body = str(json.loads(body).get("expression") or "")
    except (AttributeError, TypeError, json.JSONDecodeError):
        pass
    return (params.get("expr") or params.get("expression") or body).strip()


def lambda_handler(event, context):
    """Evaluate a math expression from the `expr` query parameter (GET)
    or the request body (POST/PUT) and return the result as JSON."""
    expression = _extract_expression(event)

    if not expression:
        return _response(400, {
            "error": "missing expression: pass ?expr=2%2B3 on GET, "
                     "or an expression in the POST/PUT body"
        })

    try:
        result = evaluate_expression(expression)
    except ValueError as e:
        return _response(400, {"expression": expression, "error": str(e)})
    except ZeroDivisionError:
        return _response(400, {"expression": expression, "error": "division by zero"})

    return _response(200, {"expression": expression, "result": result})


def _response(status_code, body):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json"},
        "body": json.dumps(body),
    }
