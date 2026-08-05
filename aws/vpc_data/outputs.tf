output "id" {
  description = "ID of the VPC."
  value       = data.aws_vpc.this.id
}

output "arn" {
  description = "ARN of the VPC."
  value       = data.aws_vpc.this.arn
}

output "cidr_block" {
  description = "Primary IPv4 CIDR block of the VPC — what a security group rule opens itself to when the caller wants VPC-wide access."
  value       = data.aws_vpc.this.cidr_block
}

# An empty list, not null, when the group was not requested. A caller passing
# these straight into a subnet group or a load balancer gets a legible "no
# subnets" failure rather than a type error several resources later.
output "private_subnet_ids" {
  description = "IDs of the subnets matching private_subnet_tags; empty when that lookup was skipped."
  value       = var.private_subnet_tags == null ? [] : one(data.aws_subnets.private[*].ids)
}

output "public_subnet_ids" {
  description = "IDs of the subnets matching public_subnet_tags; empty when that lookup was skipped."
  value       = var.public_subnet_tags == null ? [] : one(data.aws_subnets.public[*].ids)
}
