#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib/core';
import { IcdbCdnCdkStack } from '../lib/icdb-cdn-cdk-stack';

// Both URLs come from the already-deployed stacks; scripts/deploy.sh
// resolves them from CloudFormation outputs before synthesizing.
const commentsApiUrl = process.env.ICDB_API_URL;
const siteWebsiteUrl = process.env.ICDB_SITE_URL;
if (!commentsApiUrl || !siteWebsiteUrl) {
  throw new Error(
    'ICDB_API_URL and ICDB_SITE_URL must be set (see scripts/deploy.sh)',
  );
}

const app = new cdk.App();
new IcdbCdnCdkStack(app, 'IcdbCdnCdkStack', {
  commentsApiUrl,
  siteWebsiteUrl,
});
