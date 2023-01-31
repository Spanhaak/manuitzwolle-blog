# manuitzwolle terraform
This terraform builds the following components on Google Cloud Platform:
1. VPC Network
2. VPC Subnet
3. Firewall entries
4. External IP Address
5. Create the VM
6. Enable OSLOGIN/Permissions

This terraform uses two secrets to hide the actual path to my pub file and my ip address which I whitelisted to have access to the VM:

![Firewall entry](/img/screen1.png)

![SSH Access](/img/screen2.png)