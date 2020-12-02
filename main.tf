provider "aws" {
  region  = "us-east-1"
  profile = "default"
}

module "s3_module" {
  source      = "../"
  bucket_name = "aws-asset-cdn-bucket"
  job_number  = "1234-1"
  arch_number = "1"
  job_name    = "cdn-test"
  environment = "dev"
  end_date    = "00-00-0000"
  trusted_signers = ["<Aws account Number>"]
}

output "all" {
  value = {
    s3_cdn = module.s3_module
  }
}

