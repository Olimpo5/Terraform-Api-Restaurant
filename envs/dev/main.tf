
module "vm-linux-server" {
  source            = "../../modules/vm"
  aws_access_key    = var.AWS_ACCESS_KEY
  aws_secret_key    = var.AWS_SECRET_KEY
  aws_environment   = var.AWS_ENVIRONMENT
  aws_key_pair_name = var.AWS_KEY_PAIR_NAME
  aws_region        = var.AWS_REGION
  aws_restaurant_sg = var.AWS_RESTAURANT_SG
  aws_instance_type = var.AWS_INSTANCE_TYPE
  aws_server_name   = var.AWS_SERVER_NAME
  node_app_service  = var.NODE_APP_SERVICE
  node_app_email    = var.NODE_APP_EMAIL
  node_app_password = var.NODE_APP_PASSWORD
  main_domain       = var.MAIN_DOMAIN
}

output "vm-linux-server-ip" {
  value = module.vm-linux-server.aws_instance_ip
}
