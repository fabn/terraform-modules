# Look up an existing VPC and its subnets by tag, so a root that deploys *into*
# someone else's network does not have to be wired to the state that created it.
#
# The alternative is a remote state data source or a set of hardcoded ids. Both
# couple two configurations that otherwise share nothing: the first makes every
# consumer a reader of the producer's state, the second turns a network rebuild
# into an edit in every consumer. Tags are the contract AWS already provides.
#
# Read-only by construction — this module creates nothing.
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

data "aws_vpc" "this" {
  filter {
    name   = "tag:Name"
    values = [var.vpc_name]
  }
}

# One lookup per subnet group, and only for the groups a caller asks for. A root
# that places a database in private subnets has no use for the public ones, and
# an unused data source is still a call that can fail — on permissions, or on a
# tag convention that happens not to exist in that account.
data "aws_subnets" "private" {
  count = var.private_subnet_tags == null ? 0 : 1

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  dynamic "filter" {
    for_each = var.private_subnet_tags
    content {
      name   = "tag:${filter.key}"
      values = [filter.value]
    }
  }
}

data "aws_subnets" "public" {
  count = var.public_subnet_tags == null ? 0 : 1

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.this.id]
  }

  dynamic "filter" {
    for_each = var.public_subnet_tags
    content {
      name   = "tag:${filter.key}"
      values = [filter.value]
    }
  }
}
