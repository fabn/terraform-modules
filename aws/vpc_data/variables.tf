variable "vpc_name" {
  description = "Value of the VPC's Name tag."
  type        = string
}

# No default on purpose. Which tags mark a subnet private is a convention of
# whoever built the network, not something a shared module can guess: some
# estates tag `kind = private`, a cluster built for the AWS Load Balancer
# Controller tags `kubernetes.io/role/internal-elb = 1`, and picking one of
# those as a default would silently return the wrong subnets in the other.
#
# Null means "do not look these up at all" rather than "look up everything",
# so asking for one group never makes the module read the other.
variable "private_subnet_tags" {
  description = "Tags identifying the private subnets, as key/value pairs all of which must match. Null skips the lookup."
  type        = map(string)
  default     = null
}

variable "public_subnet_tags" {
  description = "Tags identifying the public subnets, as key/value pairs all of which must match. Null skips the lookup."
  type        = map(string)
  default     = null
}
