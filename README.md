# Azure Red team infrastructure using Terraform and Ansible


## Steps to follow:
1. Download and Install terraform from [Terraform Downloads](https://www.terraform.io/downloads.html) and add terraform to the PATH ([Windows](https://stackoverflow.com/questions/1618280/where-can-i-set-path-to-make-exe-on-windows)/ [Linux](https://stackoverflow.com/questions/14637979/how-to-permanently-set-path-on-linux-unix))
2. Provide you admin username and password in **mysecrets.tfvars** for Terraform and in **toupload/hosts** for Ansible. You may have to add or delete hosts depending on your requirements.
3. Run the following command for terraform (Windows: terraform.exe/Linux: terraform)
>   - `terraform.exe init`
>   - `terraform.exe plan`
>   - If there are no errors, `terraform.exec apply -auto-approve --var-file=mysecretes.tfvars`
4. At this point your infrastucture must have stood up. SSH to you ansible master `ssh <DMZ_admin_username>@guacserver.<location>.cloudapp.azure.com`
5. Run `sudo ./ansible.setup.sh`
6. Run `ansible-playbook ansible_playbook.yml`
7. That's it!! If everything went right, you would have your Red team infrastructure in Azure

## This script will produce the below infrastucture:
![alt text](http://xxx)


## Customization:
1. Change the names and number of VMs in ``variables.tf`` before executing the terraform script. Example: if you want 5 kali VMs, ``["kali1","kali2","kali3","kali4","kali5"]``. You may also want to change the names: ``["c2server", "guacserver"]``
2. Guacamole server will be installed in guacserver VM and can be accessed using ``http://guacserver.<location>.cloudapp.azure.com:8080/guacamole``. The default username/password is guacadmin/guacadmin. Change the password immediately!
3. Change the VM size and location if you want in the ``variables.tf``

## !!!IMPORTANT!!!
**mysecrets.tfvars**<br>
&nbsp;&nbsp;&nbsp;&nbsp;This contains your admin username and password. Keep it secret!<br>
**toupload/hosts**<br>
&nbsp;&nbsp;&nbsp;&nbsp;This also contains your admin username and password. Keep it secret!<br>


## References
* [Guacamole installation]



[Guacamole installation]: <https://github.com/MysticRyuujin/guac-install>