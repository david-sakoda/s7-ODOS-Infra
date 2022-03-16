terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 4.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.1.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.2.0"
    }
  }

  required_version = "~> 1.0"
}

provider "aws" {
  region = var.aws_region
}

resource "random_pet" "lambda_bucket_name" {
  prefix = "terraform-resource"
  length = 4
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket = random_pet.lambda_bucket_name.id 
  force_destroy = true
}

resource "aws_s3_bucket_acl" "lambda_bucket_acl" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "private"
}

resource "aws_s3_object" "lambda_get_all_movies_terraform" {
  bucket = aws_s3_bucket.lambda_bucket.id

  key    = "terraform-get-all-movies-java"
  source = "terraform-get-all-movies-java.zip"

  etag = filemd5("terraform-get-all-movies-java.zip")
}

resource "aws_iam_role" "terraform_lambda_exec" {
  name = "serverless_lambda"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Sid    = ""
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "terraform_lambda_policy" {
  role       = aws_iam_role.terraform_lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}


resource "aws_lambda_function" "terraform-get-all-movies-java" {
  function_name = "terraform-get-all-movies-java"

  s3_bucket = aws_s3_bucket.lambda_bucket.id
  s3_key    = aws_s3_object.lambda_get_all_movies_terraform.key

  runtime = "java11"
  handler = "com.niyam.aws.odos.movies.MoviesGetAllHandler::handleRequest"
  source_code_hash = filebase64sha256("terraform-get-all-movies-java.zip")  
  

  # vpc_config {    
  #  subnet_ids         = [aws_subnet.public-us-east-1a.id, aws_subnet.public-us-east-1b.id]
  #  security_group_ids = ["public_sg_with_aurora"]
  # } 

  role = aws_iam_role.terraform_lambda_exec.arn  
}

