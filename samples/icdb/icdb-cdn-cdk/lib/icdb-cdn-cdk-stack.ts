import * as cdk from 'aws-cdk-lib/core';
import * as cloudfront from 'aws-cdk-lib/aws-cloudfront';
import * as origins from 'aws-cdk-lib/aws-cloudfront-origins';
import { Construct } from 'constructs';

export interface IcdbCdnCdkStackProps extends cdk.StackProps {
  /** Base URL of the comments API (icdb-comms-sam ApiUrl output). */
  commentsApiUrl: string;
  /** S3 website URL of the static site (IcdbStaticCdkStack WebsiteUrl output). */
  siteWebsiteUrl: string;
}

export class IcdbCdnCdkStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: IcdbCdnCdkStackProps) {
    super(scope, id, props);

    // The bucket stores the site at the root, but viewers reach it under
    // /app — strip the prefix and resolve directory requests to index.html
    // so the S3 website origin never answers with its own redirects.
    const appUriRewrite = new cloudfront.Function(this, 'AppUriRewrite', {
      runtime: cloudfront.FunctionRuntime.JS_2_0,
      code: cloudfront.FunctionCode.fromInline(`
function handler(event) {
  var request = event.request;
  var uri = request.uri.replace(/^\\/app/, '');
  if (uri === '') uri = '/';
  if (uri.endsWith('/')) {
    uri += 'index.html';
  } else if (!uri.split('/').pop().includes('.')) {
    uri += '/index.html';
  }
  request.uri = uri;
  return request;
}
`),
    });

    // S3 website endpoints only speak HTTP.
    const siteOrigin = new origins.HttpOrigin(
      new URL(props.siteWebsiteUrl).hostname,
      { protocolPolicy: cloudfront.OriginProtocolPolicy.HTTP_ONLY },
    );

    const apiOrigin = new origins.HttpOrigin(
      new URL(props.commentsApiUrl).hostname,
      { protocolPolicy: cloudfront.OriginProtocolPolicy.HTTPS_ONLY },
    );

    const appBehavior: cloudfront.BehaviorOptions = {
      origin: siteOrigin,
      viewerProtocolPolicy: cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
      cachePolicy: cloudfront.CachePolicy.CACHING_OPTIMIZED,
      functionAssociations: [
        {
          function: appUriRewrite,
          eventType: cloudfront.FunctionEventType.VIEWER_REQUEST,
        },
      ],
    };

    const distribution = new cloudfront.Distribution(this, 'Cdn', {
      comment: 'ICDb — /app served from the site bucket, everything else from the comments API',
      defaultBehavior: {
        origin: apiOrigin,
        allowedMethods: cloudfront.AllowedMethods.ALLOW_ALL,
        cachePolicy: cloudfront.CachePolicy.CACHING_DISABLED,
        originRequestPolicy:
          cloudfront.OriginRequestPolicy.ALL_VIEWER_EXCEPT_HOST_HEADER,
        viewerProtocolPolicy: cloudfront.ViewerProtocolPolicy.REDIRECT_TO_HTTPS,
      },
      additionalBehaviors: {
        '/app': appBehavior,
        '/app/*': appBehavior,
      },
    });

    new cdk.CfnOutput(this, 'DistributionUrl', {
      value: `https://${distribution.distributionDomainName}`,
    });
  }
}
