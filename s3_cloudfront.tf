# Adquirir informações da conta AWS para configurar política de bucket
data "aws_caller_identity" "current" {}

# Bucket S3 para frontend
resource "aws_s3_bucket" "frontend_bucket" {
  bucket = "frontend-bucket"
}

# Ativar criptografia por padrão (SSE-S3) usando uma chave gerenciada pela AWS (AES-256)
resource "aws_s3_bucket_server_side_encryption_configuration" "frontend_bucket_encryption" {
  bucket = aws_s3_bucket.frontend_bucket.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256" # Usa criptografia gerenciada pela AWS
    }
  }
}

# Habilitando versionamento no bucket S3
resource "aws_s3_bucket_versioning" "versioning" {
  bucket = aws_s3_bucket.frontend_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

# Bucket para armazenar logs de acesso do S3 e CloudFront
resource "aws_s3_bucket" "log_bucket" {
  bucket = "s3-log-bucket"
}

# Habilitando logging no bucket S3 (para monitorar acessos)
resource "aws_s3_bucket_logging" "logging" {
  bucket        = aws_s3_bucket.frontend_bucket.id
  target_bucket = aws_s3_bucket.log_bucket.id
  target_prefix = "log/"
}

# Política de bucket para restringir o acesso apenas ao CloudFront (com Origin Access Control)
resource "aws_s3_bucket_policy" "frontend_bucket_policy" {
  bucket = aws_s3_bucket.frontend_bucket.id

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          "Service" : "cloudfront.amazonaws.com"
        },
        Action   = "s3:GetObject",
        Resource = "${aws_s3_bucket.frontend_bucket.arn}/*",
        Condition = {
          StringEquals = {
            "AWS:SourceArn" : "arn:aws:cloudfront::${data.aws_caller_identity.current.account_id}:distribution/${aws_cloudfront_distribution.frontend_distribution.id}"
          }
        }
      }
    ]
  })
}

# Web ACL para o AWS WAF
resource "aws_wafv2_web_acl" "frontend_waf" {
  name        = "frontend-waf"
  description = "ACL para proteger o frontend"
  scope       = "CLOUDFRONT" # Especifique que isso é para o CloudFront

  default_action {
    allow {}
  }

  rule {
    name     = "AWS-AWSManagedRulesCommonRuleSet"
    priority = 1

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    override_action {
      none {}
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "waf-metrics"
      sampled_requests_enabled   = true
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "web-acl"
    sampled_requests_enabled   = true
  }
}

# CloudFront Distribution para o bucket S3 com WAF
resource "aws_cloudfront_distribution" "frontend_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.frontend_bucket.bucket}.s3.amazonaws.com"
    origin_id   = "S3-frontend"
  }

  enabled             = true
  default_root_object = "index.html"

  default_cache_behavior {
    allowed_methods  = ["GET", "HEAD"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "S3-frontend"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none" # Não encaminhar cookies
      }
    }

    # Política de protocolo para redirecionar HTTP para HTTPS
    viewer_protocol_policy = "redirect-to-https"
  }

  # Configurando logging no CloudFront (gravar logs no bucket de logs)
  logging_config {
    include_cookies = false
    bucket          = aws_s3_bucket.log_bucket.bucket_domain_name
    prefix          = "cloudfront/"
  }

  # Adicionando restrições geográficas (opcional)
  restrictions {
    geo_restriction {
      restriction_type = "none" # Alterar para "whitelist" ou "blacklist" conforme necessidade
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }

  # Associar o WAF WebACL à distribuição CloudFront
  web_acl_id = aws_wafv2_web_acl.frontend_waf.arn
}
