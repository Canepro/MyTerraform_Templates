terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_instance" "this" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  vpc_security_group_ids = var.security_group_ids
  key_name               = var.key_name

  # Root volume configuration
  root_block_device {
    volume_type           = var.root_volume_type
    volume_size           = var.root_volume_size
    encrypted             = true
    delete_on_termination = true
  }

  # IMDSv2 enforcement for security
  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
    instance_metadata_tags      = "enabled"
  }

  # Monitoring
  monitoring = var.enable_detailed_monitoring

  # User data
  user_data = var.user_data

  # IAM instance profile
  iam_instance_profile = var.iam_instance_profile

  # Enable termination protection for production
  disable_api_termination = var.enable_termination_protection

  tags = merge(
    var.tags,
    {
      Name = var.name
    }
  )

  volume_tags = var.tags

  lifecycle {
    ignore_changes = [ami]
  }
}
