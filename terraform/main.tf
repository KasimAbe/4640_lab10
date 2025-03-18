module "web-server" {
	source = "./modules/web-server"
	project_name = "lab_week_10"
	ami = "ami-0aad88adde0bbc75c"
	key_name = "acit_4640"
	ingress_rules = [
		{
		 cidr_ipv4 = "0.0.0.0/0"
               	 from_port = 22
                 ip_protocol = "tcp"
                 to_port = 22
		},
		{
		 cidr_ipv4 = "0.0.0.0/0"
                 from_port = 80
                 ip_protocol = "tcp"
                 to_port = 80
		}
	]
	egress_rules = [
		{
		 cidr_ipv4 = "0.0.0.0/0"
                 from_port = null
                 ip_protocol = -1
                 to_port = null
		}
	]
	subnet_id = module.web-server.subnet_id.id
}
