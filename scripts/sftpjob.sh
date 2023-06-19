#!/bin/sh

##Variables - Initial Setup
#
secretName1=secret1-sftp-sshkey
secretName2=secret2-sftp-sshkey
sampleFile=testFile.dat
tmpKey1=~/.ssh/id_rsa1
tmpKey2=~/.ssh/id_rsa2
currentTime=$(date "+%Y.%m.%d-%H.%M.%S")
localPath=/staging/$sampleFile
remotePath=./data/$sampleFile
sftpUser1=sftpuser
sftpHost1=$(aws ssm get-parameter --name SFTPServer1 --query Parameter.Value --output text)
sftpUser2=sftpuser
sftpHost2=$(aws ssm get-parameter --name SFTPServer2 --query Parameter.Value --output text)

##Private Key Setup; Fetch the SSH Private Key from AWS Secrets Manager
#
mkdir -p ~/.ssh
chmod 700 ~/.ssh
touch $tmpKey1 $tmpKey2
aws secretsmanager get-secret-value --secret-id $secretName1 --query SecretString --output text > $tmpKey1
aws secretsmanager get-secret-value --secret-id $secretName2 --query SecretString --output text > $tmpKey2
chmod 700 $tmpKey1
chmod 700 $tmpKey2

##Transfer the file - Inbound from SFTP
#
sftp -i $tmpKey1 -oStrictHostKeyChecking=accept-new $sftpUser1@$sftpHost1 <<EOF
get $remotePath $localPath
EOF

##Optional data processing
#
echo $currentTime >> $localPath

##Transfer the file - Outbound to SFTP
sftp -i $tmpKey2 -oStrictHostKeyChecking=accept-new $sftpUser2@$sftpHost2 <<EOF
put $localPath $remotePath
EOF

##Remove Private Key
#
rm -f $tmpKey1 $tmpKey2

##End of Script
