# Cloudera Director Terraform

## How to create Cloudera Director instance in AWS using Terraform.

~~~bash
cd terraform/aws
terraform init
terraform apply -var 'aws_access_key=<aws access key>' -var 'aws_secret_key=<aws secret key>'
~~~

To destroy AWS objects created above.
~~~bash
terraform destroy -var 'aws_access_key=<aws access key>' -var 'aws_secret_key=<aws secret key>'
~~~

To run Cloudera Director installation process.
~~~bash
ansible-playbook  -u centos  --private-key=~/.ssh/id_rsa.cloudera.aws \
-i $(cd ../terraform/aws && terraform output director_public_ip),  \
-e "cloudera_director_env_private_key=$(sed -E 's/$/\\\\n/g' ~/.ssh/id_rsa.cloudera.aws)" \
-e "aws_access_key=<your aws access key>" \
-e "aws_secret_key=<your aws secret key" \
--vault-password-file=~/.ansible-vault-key main.yml
~~~

To destroy AWS objects created above.
~~~bash
ansible-playbook  -u centos  --private-key=~/.ssh/id_rsa.cloudera.aws \
-i $(cd ../terraform/aws && terraform output director_public_ip),  \
-e "cloudera_director_env_private_key=$(sed -E 's/$/\\\\n/g' ~/.ssh/id_rsa.cloudera.aws)" \
-e "aws_access_key=<your aws access key>" \
-e "aws_secret_key=<your aws secret key" \
--vault-password-file=~/.ansible-vault-key director-destroy.yml
~~~

~~~bash
terraform destroy -var 'aws_access_key=<aws access key>' -var 'aws_secret_key=<aws secret key>'
~~~

Please remember to encrypt you secret data stored in vault.yml
file and pass correct password to Ansible via --vault-password-file or --ask-vault-pass

BDR Replication key points:

Remember to setup clusters in different CIDR blocks in separate regions, because peering vpc requires no to have overlaps in EC2 instances addressing.

1. Import certificate for cloudera manager

/usr/java/jdk1.7.0_67-cloudera/jre/bin/keytool -importcert -alias devb -keystore /var/lib/cloudera-scm-server/certmanager/cm-auto-global_truststore.jks -file /tmp/devb.pem

File devb.pem contains fullchain certificate from source cluster located in /var/lib/cloudera-scm-server/certmanager/certs

Passwords are stored  /var/lib/cloudera-scm-server/certmanager/cm_init.txt

2. Import internal domain certificate for cloudera manager host

/usr/java/jdk1.7.0_67-cloudera/jre/bin/keytool -importcert -alias cm-devb -keystore /var/lib/cloudera-scm-server/certmanager/cm-auto-global_truststore.jks -file /tmp/cm-priv-b.pem

File cm-priv-b.pem contains certificate for internal server-agent communication and is located on source cluster in /var/lib/cloudera-scm-server/certmanager/hosts-key-store/ip-172-31-3-44.eu-west-1.compute.internal

3. Add Peering VPC between clusters in different AWS regions.
	DNS resolution from accepter VPC to private IP - Enabled
	DNS resolution from requester VPC to private IP - Enabled

4. Configure routing table on destination VPC to point to pcx target and set source cluster CIDR as a destination.

5. Keep in mind that to preserve permissions in BDR you need to use Kerberos principal which is in HDFS supergroup. To change this group go to CM -> HDFS -> Superuser Group
