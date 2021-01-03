# AWS 
* Uses shared crendential file for authentication
* Tries to install nginx in created vm so ssh is verified
* All ingress/egress ports are opened on purpose/ lazy testing
* Output is Public IP of Ubuntu, so the same can be hit from browse
  * You should see nginx welcome page

Requires Terraform 0.13 or above

### Execute with caution, tfvars file is loaded but will be committed with different extension
Defaults to,
* Mumbai 1a
* Ubuntu
* Nginx
