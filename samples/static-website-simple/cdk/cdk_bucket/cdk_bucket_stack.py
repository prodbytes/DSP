from aws_cdk import (
    CfnOutput,
    RemovalPolicy,
    Stack,
    aws_s3 as s3,
    aws_s3_deployment as s3_deployment,
)
from constructs import Construct

class CdkBucketStack(Stack):

    def __init__(self, scope: Construct, construct_id: str, **kwargs) -> None:
        super().__init__(scope, construct_id, **kwargs)

        website_bucket = s3.Bucket(
            self, "WebsiteBucket",
            website_index_document="index.html",
            public_read_access=True,
            block_public_access=s3.BlockPublicAccess(
                block_public_acls=False,
                block_public_policy=False,
                ignore_public_acls=False,
                restrict_public_buckets=False,
            ),
            removal_policy=RemovalPolicy.DESTROY,
            auto_delete_objects=True,
        )

        s3_deployment.BucketDeployment(
            self, "WebsiteDeployment",
            sources=[s3_deployment.Source.asset("../hello-website/")],
            destination_bucket=website_bucket,
        )

        CfnOutput(
            self, "WebsiteURL",
            value=website_bucket.bucket_website_url,
            description="URL of the static website",
        )
