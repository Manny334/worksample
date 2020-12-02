variable "bucket_name" {
  type        = string
  description = "Bucket Name"
}

variable "job_number" {
  type        = string
  description = "Job number"
}

variable "arch_number" {
  type        = string
  description = "architecture number"
}

variable "job_name" {
  type        = string
  description = "job name"
}

variable "environment" {
  type        = string
  description = "environment"
}

variable "end_date" {
  type        = string
  description = "End date"
}

variable "s3_force_destroy" {
  type = bool
  description = "Destroys the s3 bucket even if its full"
  default = false
}

variable "trusted_signers" {
  type = list(string)
  default = []
  description = "List of AWS account IDs (or self) that you want to allow to create signed URL for private content "  
} 

variable "s3_cors_configuration" {
  type = any
  description = "Cors configuration. https://www.terraform.io/docs/providers/aws/r/s3_bucket.html#using-cors"
  default = {}
}