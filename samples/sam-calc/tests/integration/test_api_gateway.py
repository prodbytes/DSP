import os

import boto3
import pytest
import requests

"""
Make sure env variable AWS_SAM_STACK_NAME exists with the name of the stack we are going to test.
"""


class TestApiGateway:

    @pytest.fixture()
    def api_gateway_url(self):
        """ Get the API Gateway URL from Cloudformation Stack outputs """
        stack_name = os.environ.get("AWS_SAM_STACK_NAME")

        if stack_name is None:
            raise ValueError('Please set the AWS_SAM_STACK_NAME environment variable to the name of your stack')

        client = boto3.client("cloudformation")

        try:
            response = client.describe_stacks(StackName=stack_name)
        except Exception as e:
            raise Exception(
                f"Cannot find stack {stack_name} \n" f'Please make sure a stack with the name "{stack_name}" exists'
            ) from e

        stacks = response["Stacks"]
        stack_outputs = stacks[0]["Outputs"]
        api_outputs = [output for output in stack_outputs if output["OutputKey"] == "SAMCalcApi"]

        if not api_outputs:
            raise KeyError(f"SAMCalcApi not found in stack {stack_name}")

        return api_outputs[0]["OutputValue"]  # Extract url from stack outputs

    def test_get_with_query_param(self, api_gateway_url):
        """ Evaluate an expression passed as a query parameter """
        response = requests.get(api_gateway_url, params={"expr": "2 + 3"})

        assert response.status_code == 200
        assert response.json()["result"] == 5

    def test_post_with_json_body(self, api_gateway_url):
        """ Evaluate an expression passed in a JSON body """
        response = requests.post(api_gateway_url, json={"expression": "2 * (3 + 4)"})

        assert response.status_code == 200
        assert response.json()["result"] == 14

    def test_put_with_plain_text_body(self, api_gateway_url):
        """ Evaluate an expression passed as a plain-text body """
        response = requests.put(api_gateway_url, data="10 / 4")

        assert response.status_code == 200
        assert response.json()["result"] == 2.5
