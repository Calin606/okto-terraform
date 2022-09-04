### Website
resource "aws_s3_bucket" "website" {
  bucket = "front.hlb-ip.xyz"
  acl    = "private"

  tags = {
    Environment = var.env
  }

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

data "aws_iam_policy_document" "s3_frontend_internal_policy_document" {
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.okto_front.iam_arn]
    }
  }
  statement {
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.website.arn}/*"]

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.okto_front.iam_arn]
    }
    sid = 2
  }

}

resource "aws_s3_bucket_policy" "s3_frontend_internal_policy" {
  bucket = aws_s3_bucket.website.id
  policy = data.aws_iam_policy_document.s3_frontend_internal_policy_document.json
}

resource "aws_iam_user" "github_actions_frontend" {
  name = "github_actions_frontend-${var.env}"

  tags = {
    Environment = var.env
  }
}

resource "aws_iam_user_policy" "up_website" {
  name = "okto_profiler_frontend_${var.env}_full"
  user = aws_iam_user.github_actions_frontend.name

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
        "Effect": "Allow",
        "Action": [
            "s3:ListBucket"
        ],
        "Resource": [
            "${aws_s3_bucket.website.arn}"
        ]
      },
      {
        "Effect": "Allow",
        "Action": [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
          "s3:GetObjectAcl",
          "s3:PutObjectAcl"
        ],
        "Resource": [
            "${aws_s3_bucket.website.arn}/*"
        ]
      },
        {
            "Effect": "Allow",
            "Action": [
                "cloudfront:CreateInvalidation"
            ],
            "Resource": [
                "*"
            ]
        }
  ]
}
EOF
}

resource "aws_cloudfront_origin_access_identity" "okto_front" {
  comment = "okto profiler website ${var.env}"
}

resource "aws_cloudfront_distribution" "okto_front" {
  origin {

    domain_name = aws_s3_bucket.website.bucket_regional_domain_name
    origin_id   = aws_cloudfront_origin_access_identity.okto_front.comment

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.okto_front.cloudfront_access_identity_path
    }
  }

  enabled             = true
  is_ipv6_enabled     = true
  comment             = "${var.env} distribution for website okto profiler fe"
  default_root_object = "index.html"

  aliases = [
    "front.hlb-ip.xyz",

  ]

  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = aws_cloudfront_origin_access_identity.okto_front.comment

    forwarded_values {
      query_string = true

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "redirect-to-https"
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000

  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  tags = {
    Environment = var.env
  }

  custom_error_response {
    error_code            = 403
    response_code         = 200
    error_caching_min_ttl = 0
    response_page_path    = "/index.html"
  }

  custom_error_response {
    error_code            = 404
    response_code         = 200
    error_caching_min_ttl = 0
    response_page_path    = "/index.html"
  }

  viewer_certificate {
      acm_certificate_arn            = "arn:aws:acm:us-east-1:328680576009:certificate/118cb674-c079-4a41-a418-36aab4e47c7c"
      cloudfront_default_certificate = false
      minimum_protocol_version       = "TLSv1.2_2021"
      ssl_support_method             = "sni-only"
  }
}