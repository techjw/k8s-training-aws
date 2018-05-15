## Kubernetes on AWS for Training Classes
The focus of this code is to deploy multiple, identical AWS environments for installing basic Kubernetes clusters for classroom training.
Upon successful completion, the following instances will have been provisioned per user:

* 1 k8s master node
* 2 k8s worker node
* 1 k8s ingress controller node

Additionally, a single toolbox environment/instance will have been created for centralized execution of Kismatic installs

All instances are configured with public IPs, however firewall rules will only allow SSH, kubeapi, and HTTPS access from the CIDR blocks (`local_cidr`, `toolbox_cidr`) defined in `terraform/terraform.tfvars`, or the default value as set in [variables.tf](terraform/variables.tf) if no custom CIDRs are provided.

Additionally, the following support infrastructure will be provisioned for each environment (toolbox and users):

* Custom VPC with a single subnet, associated Internet gateway, and routing table
* Security groups for allowing SSH, kubeapi, HTTPS, and internal network traffic

Since the environments generated are intended to be for simple and easy training environments, only a single SSH keypair is generated and intended to be shared with all trainees.

### Prerequisites
* Amazon Web Service account (https://aws.amazon.com/free/)
* AWS CLI (https://aws.amazon.com/cli/)
* Terraform v0.11+ (https://www.terraform.io/downloads.html)

### Provision and Build a cluster

* Create a new `terraform\terraform.tfvars` file, and specify any overrides, especially:
    * `aws_access_key`
    * `aws_secret_key`
    * `ami_id` ([Ubuntu EC2 AMI Finder](https://cloud-images.ubuntu.com/locator/ec2/) - look for 16.04 hvm:ebs-ssd)
    * `aws_region`
    * `subnet_az`
    * `local_cidr`
        * Run `curl ifconfig.co` from your local workstation and replace the IP in `local_cidr`
    * `instance_type`
        * For testing, leave it as `t2.micro`, but during live builds you may want a larger instance to handle concurrent KET installs

* Prepare common keys, initialize the toolbox instance
~~~
make create-keypair
make prepare-toolbox
make create-toolbox
~~~

* Update the [user-terraform\terraform.tfvars](user-terraform\terraform.tfvars) file:
    * Provide AWS key and secret crendentials
    * Insert the toolbox instance's public IP in `toolbox_cidr` (e.g. 54.55.56.57/32)
    * Run `curl ifconfig.co` from your local workstation and replace the IP in `local_cidr`
    * Choose a region/az, and an Ubuntu AMI for that region

* Generate the user terraform directories and create the user instances:
    * You may also modify the [Makefile](Makefile) with the users if you don't want to type them out everytime
~~~
make prepare-users USERS="user1 user2 ... userN"
make create-users USERS="user1 user2 ... userN"
~~~

* Once the deployments complete, review the `generated/trainees.yaml` and upload it to the toolbox:
~~~
scp -i ssh/cluster.pem generated/trainees.yaml ubuntu@toolbox-public.dns.or.ip:~/
~~~

* Login to the toolbox instance, then generate the user setups:
~~~
ssh -i ssh/cluster.pem ubuntu@toolbox-public.dns.or.ip
sudo ./prep-users.sh
~~~
  *  `prep-users.sh` performs the following sequence of actions:
      * Download Kismatic (v1.11.0 unless passed a different version)
      * Create the group `training`
      * Generate all users, with home directories
      * Unpacks Kismatic and copies the RSA pem to each users' home
      * Sets up each user with authorized_keys (same key as ubuntu user)
      * Generates a customized `kismatic-cluster.yaml` in each users' home, filled in with their instance names and IPs

* When finished with the training environment, you may destroy all the resources that were provisioned. To do so, run the following:
~~~
make destroy-users USERS="user1 user2 ... userN"
make destroy-toolbox
make cleanup
~~~
