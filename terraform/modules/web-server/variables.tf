variable "project_name" {
	type = string
}

variable "ami" {
	type = string
}

variable "instance_type"{
	type = string
	default = "t2.micro"
}

variable "key_name" {
	type = string
}

variable "ingress_rules" {
        type = list(object(
                {
                cidr_ipv4 = optional(string)
                from_port = optional(number)
                ip_protocol = string
                to_port = optional(number)
                }
        ))
        validation {
                condition = alltrue([
                        for rule in var.ingress_rules :
                        alltrue([rule.from_port == null, rule.to_port == null])
                        if rule.ip_protocol == "-1"
    ])
    error_message = "Ingress rules with ip_protocol = -1 must not have a from_port or to_port"
  }

}
variable "egress_rules" {
        type = list(object(
                {
                cidr_ipv4 = optional(string)
                from_port = optional(number)
                ip_protocol = string
                to_port = optional(number)
                }
	))
        validation {
                condition = alltrue([
                        for rule in var.egress_rules :
                        alltrue([rule.from_port == null, rule.to_port == null])
                        if rule.ip_protocol == "-1"
    ])
    error_message = "Egress rules with ip_protocol = -1 must not have a from_port or to_port"
  }
}


variable "subnet_id" {
        type = string
}
