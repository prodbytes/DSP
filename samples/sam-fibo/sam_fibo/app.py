import json
import sys

MAX_X = 10000000
DEFAULT_X = 0

# fibo(MAX_X) has ~2.1 million digits; lift CPython's int-to-str conversion
# limit (default 4300 digits) so json.dumps can serialize the result.
sys.set_int_max_str_digits(0)


def fibo(x):
    """Return the x-th Fibonacci number (fibo(0) = 0, fibo(1) = 1).

    Uses the fast-doubling method, O(log x) big-int multiplications,
    so large inputs stay within the Lambda timeout.
    """
    def _fib_pair(n):
        if n == 0:
            return (0, 1)
        a, b = _fib_pair(n >> 1)
        c = a * (2 * b - a)
        d = a * a + b * b
        if n & 1:
            return (d, c + d)
        return (c, d)

    return _fib_pair(x)[0]


def lambda_handler(event, context):
    """Compute fibo(x) from the `x` query string parameter (default 0).

    Parameters
    ----------
    event: dict, required
        API Gateway Lambda Proxy Input Format

        Event doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html#api-gateway-simple-proxy-for-lambda-input-format

    context: object, required
        Lambda Context runtime methods and attributes

        Context doc: https://docs.aws.amazon.com/lambda/latest/dg/python-context-object.html

    Returns
    ------
    API Gateway Lambda Proxy Output Format: dict

        Return doc: https://docs.aws.amazon.com/apigateway/latest/developerguide/set-up-lambda-proxy-integrations.html
    """

    params = event.get("queryStringParameters") or {}
    raw_x = params.get("x")

    if raw_x is None:
        x = DEFAULT_X
    else:
        try:
            x = int(raw_x)
        except ValueError:
            return _response(400, {"error": f"'x' must be an integer, got '{raw_x}'"})

    if x < 0 or x > MAX_X:
        return _response(400, {"error": f"'x' must be between 0 and {MAX_X}"})

    # fibo(x) never changes for a given x, so let clients and CDNs
    # cache successful responses for a year.
    return _response(
        200,
        {"x": x, "fibonacci": fibo(x)},
        extra_headers={"Cache-Control": "max-age=31536000"},
    )


def _response(status_code, body, extra_headers=None):
    return {
        "statusCode": status_code,
        "headers": {"Content-Type": "application/json", **(extra_headers or {})},
        "body": json.dumps(body),
    }
