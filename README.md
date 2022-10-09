# Timeoff Management Infrastructures
Web application for managing employee absences.
This project was developed in Terraform 1.3 and is built based on three infrastructures, ECS, EC2 and FARGATE. Each module deploys each infrastructure with the desired arguments.

First infrastructure
![](resources/fargate.png)

Second infrastructure
![](resources/ecs.png)

Third infrastructure
![](resources/ec2.png)

# Stand up the infrastructure


## 1. Create a bucket

Run the following command and change the parameter "bucket-name" for the name of the bucket you want to create:

    aws s3api create-bucket --bucket bucket-name 
 
## 2. Create a public key and store it on AWS 

Run the following command on linux or WSL 2 and change "my-key" name for the specific key pair you want to create:

    ssh-keygen -t rsa -b 2048 -f ~/.ssh/my-key 

This command imports the provided public key to a single region: **

    aws ec2 import-key-pair --key-name "my-key" --public-key-material fileb://~/.ssh/my-key.pub --region region-name 

## 3. Terraform init

Run the following command in the project directory and change the parameters values:

    terraform init -backend-config="bucket=my_bucket_name" -backend-config="key=environment_name/filename" 

## 4. Terraform plan

After run the previous command, run the following command and change the parameters values:

    terraform plan -var="environment=environment_name" -var="public_key=public_key_name" 

To set lots of variables, it is more convenient to specify their values in a variable definitions file (with a filename ending in either .tfvars or .tfvars.json) and then specify that file on the command line with -var-file:

    terraform plan -var-file="filename.tfvars" 

Format of the variable definition file: 

    environment = "environment_name"
    public_key = "public_key_name"

As a fallback for the other ways of defining variables, Terraform searches the environment of its own process for environment variables named TF_VAR_ followed by the name of a declared variable.

This can be useful when running Terraform in automation, or when running a sequence of Terraform commands in succession with the same variables. For example, at a bash prompt on a Unix system:

    export TF_VAR_environment=environment_name 
    export TF_VAR_public_key=public_key_name 
    terraform plan 

## 5. Terraform apply 

Finally run the command below and change the parameters values:

    terraform apply -var="environment=environment_name" -var="public_key=public_key_name" -auto-approve 

## 6. Terraform destroy

The following command will destroy the resources:

    terraform destroy -var="environment=environment_name" -var="public_key=public_key_name" -auto-approve 

## 7. Removing the working directory

Run the following command for deleting the ".terraform" directory and ".terraform.lock.hcl" file:

    rm -r .terraform/ .terraform.lock.hcl

## 8.Emptying the bucket

The following rm command removes objects that have the key name prefix doc, for example, doc/doc1 and doc/doc2:

    aws s3 rm s3://bucket-name/doc --recursive 

Use the following command to remove all objects without specifying a prefix:

    aws s3 rm s3://bucket-name --recursive 

## 9. Deleting the bucket

Run the following command and change the parameter "bucket_name" for the name of the bucket you want to delete:

    aws s3api delete-bucket --bucket bucket-name 

## 10. Deleting the key pairs

Run the following command and change the parameter values:**

    aws ec2 delete-key-pair --key-name "my-key" --region region-name 

** If you need to store/delete the key pair in more than one region, change the "region-name" and run the previous command as needed. In this case we will need to execute the command on the regions "us-east-1" and "us-west-2".

## Documentation

- [Terraform Input Variables](https://www.terraform.io/language/values/variables#input-variable-documentation)
- [Terraform Backend Configuration](https://www.terraform.io/language/settings/backends/configuration)
- [Creating AWS Bucket Resource](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html)
- [Emptying AWS Bucket Resource](https://docs.aws.amazon.com/AmazonS3/latest/userguide/empty-bucket.html)
- [Deleting AWS Bucket Resource](https://docs.aws.amazon.com/AmazonS3/latest/userguide/delete-bucket.html)
- [Import key pairs on AWS CLI](https://docs.aws.amazon.com/cli/latest/reference/ec2/import-key-pair.html)
- [Deleting key pairs on AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/cli-services-ec2-keypairs.html)