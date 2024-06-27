provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "pacepro" {
    ami = "ami-0195204d5dce06d99"
    instance_type = "t2.micro"

    tags = {
      Name = "pacepro"
      Backup = "true"
    } 
}

resource "aws_iam_role" "lambda_role" {
    name = "lambda_role"
    assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })
}

# resource "aws_iam_role_policy" "lambda_policy" {
#     name = "lambda_policy"
#     role = aws_iam_role.lambda_role.id
#     policy = jsondecode({
#         Version = "2012-10-17"
#         Statement = [
#         {
#             Action = [
#             "logs:CreateLogGroup",
#             "logs:CreateLogStream",
#             "logs:CreateLogEvents"
#         ],
#         Effect = "Allow",
#         Resource ="arn:aws:logs:*:*:*"
#         },
#         {
#             Action = "sns:Publish",
#             Effect = "Allow"
#             Resource = "*"
#         }
#       ]
#     })
# }

resource "aws_lambda_function" "pacepro" {
    function_name =  "pacepro"
    role = aws_iam_role.lambda_role.arn
    handler = "index.handler"
    runtime = "python3.10"
    filename      = "lambda_function_payload.zip"
    source_code_hash = filebase64sha256("lambda_function_payload.zip")

    environment {
    variables = {
      SNS_TOPIC_ARN = aws_sns_topic.pacepro.arn
    }
  }
}

resource "aws_sns_topic" "pacepro" {
    name = "pacepro"
}

output "ec2_instance_id" {
    value =  aws_instance.pacepro
}

output "lambda_function_name" {
    value = aws_lambda_function.pacepro
}

output "sns_topic_arn" {
    value = aws_sns_topic.pacepro.arn
  
}