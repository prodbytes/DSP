import * as cdk from 'aws-cdk-lib/core';
import { Match, Template } from 'aws-cdk-lib/assertions';
import { IcdbCdnCdkStack } from '../lib/icdb-cdn-cdk-stack';

function synth(): Template {
  const app = new cdk.App();
  const stack = new IcdbCdnCdkStack(app, 'TestStack', {
    commentsApiUrl: 'https://abc123.execute-api.us-east-1.amazonaws.com',
    siteWebsiteUrl: 'http://site.s3-website-us-east-1.amazonaws.com',
  });
  return Template.fromStack(stack);
}

test('distribution defaults to the comments API origin', () => {
  synth().hasResourceProperties('AWS::CloudFront::Distribution', {
    DistributionConfig: Match.objectLike({
      DefaultCacheBehavior: Match.objectLike({
        ViewerProtocolPolicy: 'redirect-to-https',
      }),
      Origins: Match.arrayWith([
        Match.objectLike({
          DomainName: 'abc123.execute-api.us-east-1.amazonaws.com',
        }),
        Match.objectLike({
          DomainName: 'site.s3-website-us-east-1.amazonaws.com',
          CustomOriginConfig: Match.objectLike({
            OriginProtocolPolicy: 'http-only',
          }),
        }),
      ]),
    }),
  });
});

test('app paths are routed to the site bucket with the URI rewrite', () => {
  const template = synth();
  template.hasResourceProperties('AWS::CloudFront::Distribution', {
    DistributionConfig: Match.objectLike({
      CacheBehaviors: Match.arrayWith([
        Match.objectLike({ PathPattern: '/app' }),
        Match.objectLike({ PathPattern: '/app/*' }),
      ]),
    }),
  });
  template.resourceCountIs('AWS::CloudFront::Function', 1);
});
