import json

import pytest

from sam_calc import app


def apigw_event(method="GET", query=None, body=None):
    """Generates a minimal API GW proxy event"""

    return {
        "body": body,
        "resource": "/calc",
        "path": "/calc",
        "httpMethod": method,
        "queryStringParameters": query,
        "pathParameters": None,
        "headers": {"Host": "1234567890.execute-api.us-east-1.amazonaws.com"},
        "requestContext": {
            "resourceId": "123456",
            "apiId": "1234567890",
            "resourcePath": "/calc",
            "httpMethod": method,
            "requestId": "c6af9ac6-7b61-11e6-9a41-93e8deadbeef",
            "accountId": "123456789012",
            "stage": "prod",
        },
    }


def test_get_with_query_param():
    ret = app.lambda_handler(apigw_event(query={"expr": "2 + 3"}), "")
    data = json.loads(ret["body"])

    assert ret["statusCode"] == 200
    assert data["result"] == 5


def test_post_with_json_body():
    event = apigw_event(method="POST", body='{"expression": "2 * (3 + 4)"}')
    ret = app.lambda_handler(event, "")
    data = json.loads(ret["body"])

    assert ret["statusCode"] == 200
    assert data["result"] == 14


def test_put_with_plain_text_body():
    ret = app.lambda_handler(apigw_event(method="PUT", body="10 / 4"), "")
    data = json.loads(ret["body"])

    assert ret["statusCode"] == 200
    assert data["result"] == 2.5


def test_missing_expression_returns_400():
    ret = app.lambda_handler(apigw_event(), "")

    assert ret["statusCode"] == 400
    assert "error" in json.loads(ret["body"])


def test_division_by_zero_returns_400():
    ret = app.lambda_handler(apigw_event(query={"expr": "1 / 0"}), "")

    assert ret["statusCode"] == 400
    assert json.loads(ret["body"])["error"] == "division by zero"


@pytest.mark.parametrize("expression", [
    "__import__('os').system('id')",
    "().__class__",
    "abs(-1)",
    "'a' * 100",
    "9 ** 9 ** 9",
])
def test_unsafe_expressions_are_rejected(expression):
    ret = app.lambda_handler(apigw_event(query={"expr": expression}), "")

    assert ret["statusCode"] == 400
    assert "error" in json.loads(ret["body"])
