#!/bin/bash

#################################################################
## Script:  Install the GenMetaRemove lambda function & layer,
##           S3 buckets and IAM roles & policies
## Version: 1.0.0
## Author:  Heinz Donnelly Schmidt
## Date:    14-11-23
#############################################################

## PREREQUISITES
## This deployment was created using an Ubuntu 23.10 laptop.
## If you are using MacOS or Windows please ensure you have
## the prerequisite software installed in order to be able to
## deploy this tool

## Required software:
##             	Python 3.9
## 	       	Terraform CLI (v1.6.3)
## 		AWS CLI (v2.13.34) <- Configured with 
##		  Adminisrative access to an AWS account


cd ./deploy/terraform/
terraform init
terraform plan -out getmetaremove.tfplan

echo "#####################################################"
echo " Does the above plan look in order and error free?"
read -p " Continue the deployment (y/n)?" CONT

if [ "$CONT" = "y" ]; then
  terraform apply "genmetaremove.tfplan"
  echo "Deployment complete."
else
  echo "Deployment cancelled."
fi


