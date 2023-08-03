# Repository for Blog - Enable SFTP Integration for Containerized Apps on AWS

This repository contains the Cloud Formation Templates, and other assisting files to replicate the scenario in the blog:

*Stack Architecture*

![Image](./Images/SFTP-Container-AWS%20Architecture-New.png)


Clone this repository to the local workstation and follow the instructions.

Note: 
1. This example uses ap-southeast-1 as Region-1 and ap-south as Region-2. However you are free to choose any other regions for running this sample
2. The example uses AWS Linux AMIs and the ids are hard-coded in the CFTs. Since the AMIs are region specific, the AMI ids needs to be changed in the CFTs if you choose different regions than the above

## Cloud Formation Templates 
The following templates can be used to create the basic stack.

Please execute the following Cloud Formation Templates(CFT) in respective order.

### CloudFormationTemplates/1-Network.yaml 
Please run this stack in both the regions. This will create the network pre-requisites for the later resources. This will take less than 5 minutes to complete.

### CloudFormationTemplates/2-Pre-Requisites.yaml
Please run this stack in both the regions. This will create the EC2 Key Pair, EC2 Security Group. This will take less than 5 minutes to complete.

### CloudFormationTemplates/3-ControlHub.yaml
This stack needs to be run in Region-2 only. This will create the Control Hub where you will run further CFTs. PODMAN, AWS CLI, EKSCTL and KUBECTL command binaries will be installed. This will take about 5 minutes to complete.

### CloudFormationTemplates/4a-SFTP-EC2.yaml
This stack needs to be run in Region-1 only. This will create an SFTP Server (SFTPServer1) with a Public IP address in Region-1. This will take about 5 minutes to complete.

Note: 
 1. This stack uses an ami from ap-southeast-1. If you are selecting any other region, you should change the ami id
 2. There is a dummy password for the SFTP user in this CFT. You may want to change it.

### CloudFormationTemplates/4b-SFTP-EC2.yaml
This stack needs to be run in Region-2 only. This will create an SFTP Server (SFTPServer2) with a Public IP address in Region-2. This will take about 5 minutes to complete.

Note: 
 1. This stack uses an ami from ap-south-1. If you are selecting any other region, you should change the ami id
 2. There is a dummy password for the SFTP user in this CFT. You may want to change it.

Once the above stacks are created, the following things need to be done:

    1. Fetch the IP address and create two entries `SFTPServer1` and `SFTPServer2` in SSM Parameter Store with the IP address of each of the servers.    
    2. Log into the servers and fetch the id_rsa private key for each of the server and create Secrets Manager entries `secret1-sftp-sshkey` and `secret2-sftp-sshkey`.
    3. Connect to the SFTP Server(SFTPServer1) via sftp and place a file named 'testFile.dat' in the data folder. The batch job when its run will fetch this file and push it to SFTPServer2

### CloudFormationTemplates/5-EKSCluster.yaml
Log into the ControlHub Server and execute this for straightforward usage with EKSCTL and KUBECTL Commands. 

>  aws cloudformation create-stack --stack-name Demo-EKSCluster-Stack --template-body file://5-EKSCluster.yaml --capabilities CAPABILITY_NAMED_IAM


This will create the EKS Cluster and the EKS NodeGroups. This will take about 15-20 minutes to complete.

Once the stack is created, execute the following commands to complete the setup.

> kubectl create namespace sftpbatchjob-ns

> eksctl utils associate-iam-oidc-provider --cluster MyEKSCluster --region ap-south-1 --approve

> eksctl create iamserviceaccount --name eks-sftpbatchjob-sa --namespace sftpbatchjob-ns --cluster MyEKSCluster --region ap-south-1 --role-name "EKS-sftpjob-role" --attach-policy-arn 'arn:aws:iam::aws:policy/SecretsManagerReadWrite,arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess' --approve

## Container Image
From the ControlHub Server, create an Elastic Container Registry (ECR), build the Container Image using Podman and push it to Registry.
The following commands will help you:


> repoLink=$(aws ecr create-repository --repository-name sftpdemo/sftpimage | jq -r .repository.repositoryUri)

> aws ecr get-login-password --region ap-south-1 | podman login --username AWS --password-stdin $repoLink

> podman build -t sftpimage .

> podman tag sftpimage:latest $repoLink:1.0

> podman push $repoLink:1.0


## Create the Kubernetes CronJob

Once the setup is complete, create the CronJob from the yaml file.

> kubectl create -f sftpbatchjob.yaml

> kubectl get all --namespace sftpbatchjob-ns

Monitor for job completion and view the results via pod logs.

> kubectl logs pod/sftp-batch-job-28123515-blc4n --namespace sftpbatchjob-ns




**DISCLAIMER:** The code shared here may not follow the security best practices. This is a tested and working code used in the blog. Use with proper due diligence. Not for Production use. Please perform necessary cleanup via Stack deletion to avoid recurring costs.

