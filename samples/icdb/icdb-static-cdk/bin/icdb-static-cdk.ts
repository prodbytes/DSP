#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib/core';
import { IcdbStaticCdkStack } from '../lib/icdb-static-cdk-stack';

const app = new cdk.App();
new IcdbStaticCdkStack(app, 'IcdbStaticCdkStack');
