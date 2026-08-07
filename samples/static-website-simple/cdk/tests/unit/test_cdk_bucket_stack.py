import aws_cdk as core
import aws_cdk.assertions as assertions

from cdk_bucket.cdk_bucket_stack import CdkBucketStack

# example tests. To run these tests, uncomment this file along with the example
# resource in cdk_bucket/cdk_bucket_stack.py
def test_sqs_queue_created():
    app = core.App()
    stack = CdkBucketStack(app, "cdk-bucket")
    template = assertions.Template.from_stack(stack)

#     template.has_resource_properties("AWS::SQS::Queue", {
#         "VisibilityTimeout": 300
#     })
