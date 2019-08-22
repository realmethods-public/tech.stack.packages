#!/bin/bash

terraform version
terraform init --input=false /code/gitRoot/terraform
#if ( $aib.getParam( "kubernetes.inUse" ) == "true" )
terraform plan --input=false --out=terraform.plan -var host=${aib.getParam("kubernetes.host")} -var username=${aib.getParam("kubernetes.username")} -var password=${aib.getParam("kubernetes.password")} -var region=${aib.getParam("kubernetes.region")} -var project=${aib.getParam("kubernetes.project")} /code/gitRoot/terraform
#else
terraform plan --input=false --out=terraform.plan -var aws-access-key=${aib.getParam("terraform.aws-access-key")} -var aws-secret-key=${aib.getParam("terraform.aws-secret-key")} /code/gitRoot/terraform
#end ##if ( $aib.getParam( "kubernetes.inUse" ) == "true" )
terraform apply --input=false "terraform.plan"