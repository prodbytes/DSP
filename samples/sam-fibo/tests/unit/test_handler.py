import json

import pytest

from sam_fibo import app


def apigw_event(query_params):
    """ Generates API GW Event"""

    return {
        "body": None,
        "resource": "/fibo",
        "requestContext": {
            "resourceId": "123456",
            "apiId": "1234567890",
            "resourcePath": "/fibo",
            "httpMethod": "GET",
            "requestId": "c6af9ac6-7b61-11e6-9a41-93e8deadbeef",
            "accountId": "123456789012",
            "identity": {
                "apiKey": "",
                "userArn": "",
                "cognitoAuthenticationType": "",
                "caller": "",
                "userAgent": "Custom User Agent String",
                "user": "",
                "cognitoIdentityPoolId": "",
                "cognitoIdentityId": "",
                "cognitoAuthenticationProvider": "",
                "sourceIp": "127.0.0.1",
                "accountId": "",
            },
            "stage": "prod",
        },
        "queryStringParameters": query_params,
        "headers": {
            "Via": "1.1 08f323deadbeefa7af34d5feb414ce27.cloudfront.net (CloudFront)",
            "Accept-Language": "en-US,en;q=0.8",
            "CloudFront-Is-Desktop-Viewer": "true",
            "CloudFront-Is-SmartTV-Viewer": "false",
            "CloudFront-Is-Mobile-Viewer": "false",
            "X-Forwarded-For": "127.0.0.1, 127.0.0.2",
            "CloudFront-Viewer-Country": "US",
            "Accept": "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8",
            "Upgrade-Insecure-Requests": "1",
            "X-Forwarded-Port": "443",
            "Host": "1234567890.execute-api.us-east-1.amazonaws.com",
            "X-Forwarded-Proto": "https",
            "X-Amz-Cf-Id": "aaaaaaaaaae3VYQb9jd-nvCd-de396Uhbp027Y2JvkCPNLmGJHqlaA==",
            "CloudFront-Is-Tablet-Viewer": "false",
            "Cache-Control": "max-age=0",
            "User-Agent": "Custom User Agent String",
            "CloudFront-Forwarded-Proto": "https",
            "Accept-Encoding": "gzip, deflate, sdch",
        },
        "pathParameters": None,
        "httpMethod": "GET",
        "stageVariables": {"baz": "qux"},
        "path": "/fibo",
    }


@pytest.mark.parametrize("x, expected", [(0, 0), (1, 1), (2, 1), (10, 55), (20, 6765)])
def test_lambda_handler_computes_fibonacci(x, expected):
    ret = app.lambda_handler(apigw_event({"x": str(x)}), "")
    data = json.loads(ret["body"])

    assert ret["statusCode"] == 200
    assert data == {"x": x, "fibonacci": expected}
    assert ret["headers"]["Cache-Control"] == "max-age=31536000"


def test_lambda_handler_missing_x_defaults_to_zero():
    ret = app.lambda_handler(apigw_event(None), "")
    data = json.loads(ret["body"])

    assert ret["statusCode"] == 200
    assert data == {"x": 0, "fibonacci": 0}


def test_lambda_handler_large_x():
    ret = app.lambda_handler(apigw_event({"x": "100000"}), "")
    data = json.loads(ret["body"])

    assert ret["statusCode"] == 200
    assert data["x"] == 100000
    assert len(str(data["fibonacci"])) == 20899  # fibo(100000) has 20899 digits


def test_lambda_handler_non_integer_x():
    ret = app.lambda_handler(apigw_event({"x": "abc"}), "")
    data = json.loads(ret["body"])

    assert ret["statusCode"] == 400
    assert "error" in data


@pytest.mark.parametrize("x", ["-1", str(app.MAX_X + 1)])
def test_lambda_handler_out_of_range_x(x):
    ret = app.lambda_handler(apigw_event({"x": x}), "")
    data = json.loads(ret["body"])

    assert ret["statusCode"] == 400
    assert "error" in data
