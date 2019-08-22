#####################################################################
# Google Cloud Platform
#####################################################################
provider "google" {
  credentials = "${esc.dollar}{file("/code/gitRoot/terraform/account.json")}"
  project = "${var.project}"
  region  = "${var.region}"
}