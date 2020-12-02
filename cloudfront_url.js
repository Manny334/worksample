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
  url: 'https://dux2qm168yhl1.cloudfront.net/private/firefox_logo.jpg',
  expires: Math.floor((Date.now() + oneMin)/1000), 
})

const public_signedUrl = signer.getSignedUrl({
  url: 'https://dux2qm168yhl1.cloudfront.net/public/logo.jpg',
  expires: Math.floor((Date.now() + oneMin)/1000), 
})

console.log('private_signedUrl: '+private_signedUrl);

console.log('public_signedUrl: '+public_signedUrl);






