# Cloudera Director Terraform

## How to create Cloudera Director instance in AWS using Terraform.

~~~~ 
cd terraform/aws 
terraform init
terraform apply -var 'aws_access_key=<aws access key>' -var 'aws_secret_key=<aws secret key>'
~~~~ 

To destroy AWS objects created above.
~~~~ 
terraform destroy -var 'aws_access_key=<aws access key>' -var 'aws_secret_key=<aws secret key>'
~~~~
