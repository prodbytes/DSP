# sam-calc

This project contains source code and supporting files for a serverless calculator API that you can deploy with the SAM CLI. It evaluates arithmetic expressions such as `2 + 3` sent as a query parameter (GET) or in the request body (POST/PUT). It includes the following files and folders.

- sam_calc - Code for the application's Lambda function.
- events - Invocation events that you can use to invoke the function.
- tests - Unit and integration tests for the application code.
- scripts - Deploy and destroy scripts for the stack.
- template.yaml - A template that defines the application's AWS resources.

The application uses several AWS resources, including Lambda functions and an API Gateway API. These resources are defined in the `template.yaml` file in this project. You can update the template to add AWS resources through the same deployment process that updates your application code.

Only numeric literals, the operators `+ - * / // % **`, and parentheses are accepted; any other Python syntax (names, calls, attributes) is rejected with a `400` response.

## Deploy the sample application

The Serverless Application Model Command Line Interface (SAM CLI) is an extension of the AWS CLI that adds functionality for building and testing Lambda applications. It uses Docker to run your functions in an Amazon Linux environment that matches Lambda. It can also emulate your application's build environment and API.

To use the SAM CLI, you need the following tools.

* SAM CLI - [Install the SAM CLI](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-install.html)
* [Python 3 installed](https://www.python.org/downloads/)
* Docker - [Install Docker community edition](https://hub.docker.com/search/?type=edition&offering=community)

To build and deploy the application, run:

```bash
sam-calc$ ./scripts/deploy.sh
```

The script builds the application, deploys the `sam-calc` stack without prompts, and prints the API Gateway endpoint URL. To tear everything down:

```bash
sam-calc$ ./scripts/destroy.sh
```

Alternatively, deploy manually with `sam build --use-container` followed by `sam deploy --guided`.

## Call the API

Grab the endpoint URL from the stack outputs:

```bash
API_URL="$(aws cloudformation describe-stacks --stack-name sam-calc \
  --query "Stacks[0].Outputs[?OutputKey=='SAMCalcApi'].OutputValue" --output text)"
```

Then evaluate expressions with curl. Note that `+` must be URL-encoded as `%2B` in a query string (or use `--data-urlencode`):

```bash
# GET with a query parameter
curl "${API_URL}?expr=2%2B3"
# {"expression": "2+3", "result": 5}

# GET, letting curl handle the URL encoding
curl -G "${API_URL}" --data-urlencode "expr=2 + 3"

# POST with a JSON body
curl -X POST "${API_URL}" -H "Content-Type: application/json" \
  -d '{"expression": "2 * (3 + 4)"}'
# {"expression": "2 * (3 + 4)", "result": 14}

# PUT with a plain-text body
curl -X PUT "${API_URL}" -d "10 / 4"
# {"expression": "10 / 4", "result": 2.5}
```

## Use the SAM CLI to build and test locally

Build your application with the `sam build --use-container` command.

```bash
sam-calc$ sam build --use-container
```

The SAM CLI installs dependencies defined in `sam_calc/requirements.txt`, creates a deployment package, and saves it in the `.aws-sam/build` folder.

Test a single function by invoking it directly with a test event. An event is a JSON document that represents the input that the function receives from the event source. Test events are included in the `events` folder in this project.

Run functions locally and invoke them with the `sam local invoke` command.

```bash
sam-calc$ sam local invoke SAMCalcFunction --event events/event.json
```

The SAM CLI can also emulate your application's API. Use the `sam local start-api` to run the API locally on port 3000.

```bash
sam-calc$ sam local start-api
sam-calc$ curl "http://localhost:3000/calc?expr=2%2B3"
```

The SAM CLI reads the application template to determine the API's routes and the functions that they invoke. The `Events` property on each function's definition includes the route and method for each path.

```yaml
      Events:
        CalcGet:
          Type: Api
          Properties:
            Path: /calc
            Method: get
```

## Add a resource to your application
The application template uses AWS Serverless Application Model (AWS SAM) to define application resources. AWS SAM is an extension of AWS CloudFormation with a simpler syntax for configuring common serverless application resources such as functions, triggers, and APIs. For resources not included in [the SAM specification](https://github.com/awslabs/serverless-application-model/blob/master/versions/2016-10-31.md), you can use standard [AWS CloudFormation](https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-template-resource-type-ref.html) resource types.

## Fetch, tail, and filter Lambda function logs

To simplify troubleshooting, SAM CLI has a command called `sam logs`. `sam logs` lets you fetch logs generated by your deployed Lambda function from the command line. In addition to printing the logs on the terminal, this command has several nifty features to help you quickly find the bug.

`NOTE`: This command works for all AWS Lambda functions; not just the ones you deploy using SAM.

```bash
sam-calc$ sam logs -n SAMCalcFunction --stack-name "sam-calc" --tail
```

You can find more information and examples about filtering Lambda function logs in the [SAM CLI Documentation](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/serverless-sam-cli-logging.html).

## Tests

Tests are defined in the `tests` folder in this project. Use PIP to install the test dependencies and run tests.

```bash
sam-calc$ pip install -r tests/requirements.txt --user
# unit test
sam-calc$ python -m pytest tests/unit -v
# integration test, requiring deploying the stack first.
# Create the env variable AWS_SAM_STACK_NAME with the name of the stack we are testing
sam-calc$ AWS_SAM_STACK_NAME="sam-calc" python -m pytest tests/integration -v
```

## Cleanup

To delete the sample application that you created, run the destroy script (or use `sam delete --stack-name "sam-calc"` directly):

```bash
sam-calc$ ./scripts/destroy.sh
```

## Resources

See the [AWS SAM developer guide](https://docs.aws.amazon.com/serverless-application-model/latest/developerguide/what-is-sam.html) for an introduction to SAM specification, the SAM CLI, and serverless application concepts.

Next, you can use AWS Serverless Application Repository to deploy ready to use Apps that go beyond basic samples and learn how authors developed their applications: [AWS Serverless Application Repository main page](https://aws.amazon.com/serverless/serverlessrepo/)
