

module "vm-linux-server" {
  source            = "../../modules/vm"
  aws_access_key    = var.aws_access_key
  aws_secret_key    = var.aws_secret_key
  aws_environment   = var.aws_environment
  aws_key_pair_name = var.aws_key_pair_name
  aws_region        = var.aws_region
  aws_restaurant_sg = var.aws_restaurant_sg
  aws_instance_type = var.aws_instance_type
  aws_server_name   = var.aws_server_name
  node_app_service  = var.node_app_service
}

output "vm-linux-server-ip" {
  value = module.vm-linux-server.aws_instance_ip
}
