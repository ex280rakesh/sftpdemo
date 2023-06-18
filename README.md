# Repository for Blog - Enable SFTP Integration for Containerized Apps on AWS

Please execute the following Cloud Formation Templates(CFT) in respective order.

## 1-Network.yaml
This will create the network pre-requisites for the later resources.

## 2- Pre-Requisites
This is

## 2-ControlHub.yaml
This will create the Control Hub where you will run further

## 3-SFTP-EC2.yaml

## 4-EKSCluster.yaml
Execute

- `dev`: Contains the latest code **and it is the branch actively developed**. Note that **all PRs must be against the `dev` branch to be considered**. This branch is developed using `.NET 7`
- `release/net-6`: Contains the code changes specific to the `.NET 6`
- `release/net-5`: Contains the code changes specific to the `.NET 5`
- `release/net-3.1.1`: Contains the code changes specific to the `.NET 3.1`

> [!DISCLAIMER]: The code shared here may not follow the security best practices. This is a tested and working code used in the blog. Use with proper due diligence. Not for Production use.

