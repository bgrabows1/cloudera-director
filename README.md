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

### BDR

This feature is available only with a Cloudera Enterprise license. It is not available in Cloudera Express.
To use HDFS replication, both the destination and source HDFS services must use Kerberos authentication, or both must not use Kerberos authentication.
Remember to setup clusters in different CIDR blocks in separate regions, because peering vpc requires no to have overlaps in EC2 instances addressing.

1. Import certificate for cloudera manager
```
/usr/java/jdk1.7.0_67-cloudera/jre/bin/keytool -importcert -alias devb -keystore /var/lib/cloudera-scm-server/certmanager/cm-auto-global_truststore.jks -file /tmp/devb.pem
```
File devb.pem contains fullchain certificate from source cluster located in /var/lib/cloudera-scm-server/certmanager/certs

Passwords are stored  /var/lib/cloudera-scm-server/certmanager/cm_init.txt

2. Import internal domain certificate for cloudera manager host

```
/usr/java/jdk1.7.0_67-cloudera/jre/bin/keytool -importcert -alias cm-devb -keystore /var/lib/cloudera-scm-server/certmanager/cm-auto-global_truststore.jks -file /tmp/cm-priv-b.pem
```

File cm-priv-b.pem contains certificate for internal server-agent communication and is located in source cluster in /var/lib/cloudera-scm-server/certmanager/hosts-key-store/ip-172-31-3-44.eu-west-1.compute.internal

3. Add Peering VPC between clusters in different AWS regions.
	DNS resolution from accepter VPC to private IP - Enabled
	DNS resolution from requester VPC to private IP - Enabled

4. Configure routing table on destination VPC to point to pcx target and set source cluster CIDR as a destination.

5. To preserve permissions to HDFS, you must be running as a superuser on the destination cluster. Use the "Run As Username" option to ensure that is the case.
	 Keep in mind that to preserve permissions in BDR you need to use Kerberos principal which is in HDFS supergroup. To change this group go to CM -> HDFS -> Superuser Group

6. If you are using different Kerberos principals for the source and destination clusters, add the destination principal as a proxy user on the source cluster. For example, if you are using the hdfssrc principal on the source cluster and the hdfsdest principal on the destination cluster, add the following properties to the HDFS service Cluster-wide Advanced Configuration Snippet (Safety Valve) for core-site.xml property on the source cluster:

```
<property>
    <name>hadoop.proxyuser.hdfsdest.groups</name>
    <value>*</value>
</property>
<property>
    <name>hadoop.proxyuser.hdfsdest.hosts</name>
    <value>*</value>
</property>
```

#### BDR and encrypted data

You must skip checksum checks to prevent replication failure due to non-matching checksums in the following cases:

	- Replications from an encrypted zone on the source cluster to an encrypted zone on a destination cluster.
	- Replications from an encryption zone on the source cluster to an unencrypted zone on the destination cluster.
	- Replications from an unencrypted zone on the source cluster to an encrypted zone on the destination cluster.

### Hive

1. Connect to Hive using beeline :
```
beeline -u "jdbc:hive2://ip-172-31-3-231.eu-west-1.compute.internal:10000/;principal=hive/ip-172-31-3-231.eu-west-1.compute.internal@DIRECTOR.DEVB.CLDADR.NET;ssl=true;sslTrustStore=/var/lib/cloudera-scm-agent/agent-cert/cm-auto-in_cluster_truststore.jks"
```
```
create database hive_repl_db location '/user/centos/hive-replication-test';
```
```
> use hive_repl_db;

> create external table hive_repl_tbl (id int, name string) location '/user/centos/hive-replication-test';
```
To enable Sentry authorization configure HDFS service:
HDFS -> Configuration ->
                        dfs.namenode.acls.enabled = HDFS
                        dfs.permissions.supergroup = <group_contains_your_user>

Hive -> Configuration ->
                        Sentry Service = Sentry

To be able to create role in Hive for Sentry authorization you need to be in at least one group specified in Sentry service.

Sentry -> Configuration -> sentry.service.admin.group

Keep in mind that you have to use beeline to create Sentry role. Hive client bypasses Sentry by default.
Check your "Server Name for Sentry Authorization" before:

Hive -> Configuration -> hive.sentry.server
```
> create role hive_sentry_rw;
> grant all on server server1 to role hive_sentry_rw with grant option;
> grant role hive_sentry_rw to group centos;
```


### Kerberized Kafka

1. jaas.conf
```
KafkaClient {
        com.sun.security.auth.module.Krb5LoginModule required
        useTicketCache=true;
};
```

2. client.properties
```
security.protocol=SASL_PLAINTEXT
sasl.kerberos.service.name=kafka
```
```
export KAFKA_OPTS="-Djava.security.auth.login.config=/home/centos/jaas.conf"

kafka-console-producer --broker-list ip-10-0-3-216.eu-west-2.compute.internal:9092 --topic test1 --producer.config /home/centos/client.properties

kafka-console-consumer --bootstrap-server ip-10-0-3-216.eu-west-2.compute.internal:9092 --topic test1 --from-beginning --consumer.config /home/centos/client.properties
```
