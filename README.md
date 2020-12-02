# Terraform module for creating a CloudFront signed URL

This repo contains the code for creating cloudfront signed URL. 

# Usage
```
provider "aws" {
  region  = "us-east-1"
  profile = "<your-account>-24g"
}

module "s3_module" {
  source      = "../"
  bucket_name = "<Bucket-name>"
  job_number  = "1234-1"
  arch_number = "1"
  job_name    = "<Job-name>"
  environment = "<Environment>"
  end_date    = "00-00-0000"
  trusted_signers = ["<AWS-account-number>"]
}

output "all" {
  value = {
    s3_cdn = module.s3_module
  }
} 
```

## Node.js script for creating the cloudfront signed URL 

```
// load the AWS SDK
const AWS = require('aws-sdk')

// load CloudFront key pair from environment variables
// Important: when storing your CloudFront private key as an environment variable string, 
// you'll need to replace all line breaks with \n, like this:
// CF_PRIVATE_KEY="-----BEGIN RSA PRIVATE KEY-----\nMIIE...1Ar\nwLW...2eL\nFOu...k2E\n-----END RSA PRIVATE KEY-----"
const cloudfrontAccessKeyId = process.env.CF_ACCESS_KEY_ID
const cloudFrontPrivateKey = process.env.CF_PRIVATE_KEY
const signer = new AWS.CloudFront.Signer(cloudfrontAccessKeyId, cloudFrontPrivateKey)

// 1 Min as milliseconds to use for link expiration
const oneMin = 60*1000

// sign a CloudFront URL that expires 1 days from now
const private_signedUrl = signer.getSignedUrl({
  url: 'https://<your-cloudfront-domain-name>/path/to/file',
  expires: Math.floor((Date.now() + oneMin)/1000), 
})

const public_signedUrl = signer.getSignedUrl({
  url: 'https://<your-cloudfront-domain-name>/path/to/file',
  expires: Math.floor((Date.now() + oneMin)/1000), 
})

console.log('private_signedUrl: '+private_signedUrl);

console.log('public_signedUrl: '+public_signedUrl);

```

## Creation of Path Patterns

 * Define path patterns and their sequence carefully or you may give users undesired access to your content. For example,
suppose a request matches the path pattern for two cache behaviors. The first cache behavior does not require signed URL
and second cache behavior does require signed URLs. Users are able to access the objects without using a signed URL because 
cloudfront processesthe cache bahevior associated with the first match. 

