terraform {
    required_version = ">=0.12.0"
    backend "s3" {
        region= "us-east-1"
    }
}

provider "aws" {
    region = "us-east-1"
    alias = "main_region"
}