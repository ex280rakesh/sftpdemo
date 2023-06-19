# Repository for Blog - Enable SFTP Integration for Containerized Apps on AWS



## Cloud Formation Templates 
The following templates can be used to create the basic stack requried for replicating the scenario

Please execute the following Cloud Formation Templates(CFT) in respective order.

### CloudFormationTemplates/1-Network.yaml
This will create the network pre-requisites for the later resources.

### CloudFormationTemplates/2-Pre-Requisites.yaml
This will create the EC2 Key Pair, EC2 Security Group

### CloudFormationTemplates/3-ControlHub.yaml
This will create the Control Hub where you will run further CFTs. PODMAN, AWS CLI, EKSCTL and KUBECTL command binaries will be installed. Create the EKS cluster from this machine.

### CloudFormationTemplates/4-SFTP-EC2.yaml
This will create 2 SFTP Servers on with Public IP address. Once the stack is created, the following things need to be done:
    1. Fetch the IP address and create two entries `SFTPServer1` and `SFTPServer2` in SSM Parameter Store with the IP address of each of the servers.
    2. Log into the servers and fetch the id_rsa private key for each of the server and create Secrets Manager entries `secret1-sftp-sshkey` and `secret2-sftp-sshkey`.

### CloudFormationTemplates/5-EKSCluster.yaml
Execute this from the ControlHub Server for straightforward usage with EKSCTL and KUBECTL Commands.

>  aws cloudformation create-stack --stack-name Demo-EKSCluster-Stack \
 --template-body file://5-EKSCluster.yaml --capabilities CAPABILITY_NAMED_IAM


This will create the EKS Cluster and the EKS NodeGroups. Once the stack is created, execute the following commands to complete the setup.
> 

kubectl create namespace sftpbatchjob-ns

eksctl create iamserviceaccount --name my-eks-cluster-sa \
 --namespace sftpbatchjob-ns --cluster myekscluster --role-name "EKS-secrets-role" \ 
--attach-policy-arn arn:aws:iam::aws:policy/SecretsManagerReadWrite  --approve

kubectl create -f mysftpjob.yml

## Container Image
From the ControlHub Server, build the Container Image using Podman and push it to Elastic Container Registry(ECR)
Commands:
>

repoLink=$(aws ecr create-repository --repository-name \
sftpdemo/sftpimage | jq -r .repository.repositoryUri)

aws ecr get-login-password --region ap-south-1 | \
podman login --username AWS --password-stdin $repoLink

podman tag sftpimage:latest $repoLink:1.0
podman push $repoLink:1.0


##



**DISCLAIMER:** The code shared here may not follow the security best practices. This is a tested and working code used in the blog. Use with proper due diligence. Not for Production use.

