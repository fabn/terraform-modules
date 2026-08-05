# The module reads AWS and creates nothing, so the provider is mocked: what is
# worth asserting is the lookup logic, not the values AWS would return.
#
# The one behaviour with real logic in it is the conditional lookup — a group
# whose tags are null must not be read, and must still produce a usable empty
# list rather than null.

mock_provider "aws" {
  mock_data "aws_vpc" {
    defaults = {
      id         = "vpc-0123456789abcdef0"
      arn        = "arn:aws:ec2:eu-south-1:123456789012:vpc/vpc-0123456789abcdef0"
      cidr_block = "10.0.0.0/16"
    }
  }

  mock_data "aws_subnets" {
    defaults = {
      ids = ["subnet-aaa", "subnet-bbb", "subnet-ccc"]
    }
  }
}

run "vpc_attributes_come_from_the_name_lookup" {
  command = apply

  variables {
    vpc_name = "example-vpc"
  }

  assert {
    condition     = output.id == "vpc-0123456789abcdef0"
    error_message = "the VPC id should come from the Name tag lookup"
  }

  assert {
    condition     = output.cidr_block == "10.0.0.0/16"
    error_message = "the CIDR block should be published for callers writing VPC-wide rules"
  }
}

run "no_subnet_tags_means_no_subnet_lookup" {
  command = apply

  variables {
    vpc_name = "example-vpc"
  }

  assert {
    condition     = length(data.aws_subnets.private) == 0 && length(data.aws_subnets.public) == 0
    error_message = "a caller asking for no subnet group should trigger no subnet lookup"
  }

  # Empty rather than null: a caller passing this into a subnet group gets a
  # legible "no subnets" failure instead of a type error further down.
  assert {
    condition     = output.private_subnet_ids == [] && output.public_subnet_ids == []
    error_message = "a skipped lookup should still produce an empty list"
  }
}

run "each_group_is_looked_up_independently" {
  command = apply

  variables {
    vpc_name            = "example-vpc"
    private_subnet_tags = { "kubernetes.io/role/internal-elb" = "1" }
  }

  assert {
    condition     = length(data.aws_subnets.private) == 1
    error_message = "requesting the private group should trigger its lookup"
  }

  assert {
    condition     = length(data.aws_subnets.public) == 0
    error_message = "requesting the private group should not trigger the public one"
  }

  assert {
    condition     = length(output.private_subnet_ids) == 3
    error_message = "the private subnet ids should be published"
  }

  assert {
    condition     = output.public_subnet_ids == []
    error_message = "the group that was not requested should stay empty"
  }
}

run "both_groups_can_be_requested_together" {
  command = apply

  variables {
    vpc_name            = "example-vpc"
    private_subnet_tags = { "kind" = "private" }
    public_subnet_tags  = { "kind" = "public" }
  }

  assert {
    condition     = length(output.private_subnet_ids) == 3 && length(output.public_subnet_ids) == 3
    error_message = "both groups should be published when both are requested"
  }
}
