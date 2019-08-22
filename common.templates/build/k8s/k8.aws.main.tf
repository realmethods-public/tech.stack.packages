#####################################################################
# Variables
#####################################################################
variable "username" {
  default = "admin"
}
variable "password" {}
variable "project" {}
variable "region" {}

#####################################################################
# Modules
#####################################################################
module "eks" {
  source   = "./eks"
  project  = "${var.project}"
  region   = "${var.region}"
  username = "${var.username}"
  password = "${var.password}"
}

module "k8s" {
  source   = "./k8s"
  host     = "${module.gke.host}"
  username = "${var.username}"
  password = "${var.password}"

  client_certificate     = "${module.eks.client_certificate}"
  client_key             = "${module.eks.client_key}"
  cluster_ca_certificate = "${module.eks.cluster_ca_certificate}"
}