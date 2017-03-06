### F5 Office 365 SAML Federation Solution Template ###

### Description ###
Microsoft Office 365 is a popular choice when you are looking to outsource the management and infrastructure costs of running commodity applications like email and other productivity tools. Office 365 enables the use of a federated identity model that gives you full control of a user's identity, including their password hashes.

Using F5 BIG-IP with Access Policy Manager, (APM) lets you to provide secure, federated identity management from your existing Active Directory to Office 365, without the complexity of additional layers of Active Directory Federation Services (ADFS) servers and proxy servers. You can use many of the enhanced APM security features, such as geographical restrictions and multi-factor authentication, to further protect access to Office 365.

To properly configure and utilize the F5 o365 federation solution it will be necessary for the BIG-IP to have access to one your organization's domain controllers.  This enables the BIG-IP to pre-authenticate users against the organization's active directory. Typically, this can be accomplished by either establishing secure connectivity, (i.e. IPSec VPN or Express Route) between the Azure environment and the corporate infrastructure or by maintaining a read-only domain controller copy in Azure. The configuration will look like the following diagram:

![alt tag](https://raw.githubusercontent.com/gregcoward/f5-o365fed-byol/master/o365.png)

In addition to configuring the F5 federation IdP service, it will be necessary to configure the o365 environment via powershell.  Addtional information on configuring the o365 enviroment and the BIG-IP as the federation endpoint can be found at <a href="https://www.f5.com/pdf/deployment-guides/microsoft-office-365-idp-dg.pdf" target="_blank"></a> 

### F5 BIG-IP instance types and pricing tiers ###

You choose the throughput and corresponding Azure instance based on the number of cores and throughput you need. The instances listed below are minimums; you can choose larger instances if you want.

| Cores | Througput | Minimum Azure Instance |
| --- | --- | --- |
| 2 | 25 Mbps | D2_v2 |
| 4 | 200 Mbps | A3 Standard or D3_v2 |
| 8 | 1 Gbps | A4 or A7 Standard or D4v2 |

### Template parameters ###

| Parameter | Required | Description |
| --- | --- | --- |
| instanceType | x | The desired Azure Virtual Machine instance size. |
| instanceThroughput | x | The desired Azure Virtual Machine instance throughput. The values are 1G, 200M, and 25M. |
| adminUsername | x | A user name to login to the BIG-IPs.  The default value is "azureuser". |
| adminPassword | x | A strong password for the BIG-IPs. Remember this password; you will need it later. |
| sshKey | x | An alternative to password authentication with the BIG-IPs. |
| virtualNetwork | x | Select from either a new virtual network or attach the BIG-IP(s) to an existing virtual network. |
| bigipIP | x | For existing virtual networks, select an ip address to assign to the first BIG-IP.  If selected, the IP address for the second BIG-IP will be assigned sequentially. |
| restrictedSrcAddress | x | Restricts management access to a specific network or address. Enter a IP address or address range in CIDR notation, or asterisk for all sources. |
| authFqdn | x | The FQDN of primary AD domain controller used for user authentication. |
| authIp | x | The IP address of primary AD domain controller used for user authentication. |
| domainFqdn | x | The federated domain suffix, (for example: 'fdemo.net'). |
| dnsFqdn | x | The public federation endpoint FQDN, (for example: 'fs.fdemo.net'). |
| sslCert | x | Browse to and select the SSL certificate, (.pfx format) file corresponding to public facing VIP. |
| sslPswd | x | The passphrase to open the .pfx certificate file. |


### Results ###

This template will create a new resource group, and inside this new resource group it will configure the following:

* Availability Set
* Azure Load Balancer
* Network Security Group
* Storage Account
* Public IP Address
* Network Interface objects for the F5 SAML federation devices
* F5 SAML Federation Virtual Machines

![alt tag](https://raw.githubusercontent.com/gregcoward/f5-o365fed-byol/master/o3652.png)

### Connecting to the management interface of the F5 o365 Federation virtual machine(s) ###

After the deployment successfully finishes, you can find the BIG-IP Management UI\SSH URLs by doing the following: 

* Find the resource group that was deployed and select 'Deployments'.  When you click on this object you will see the deployment status.  
* Click on the deployment status, and then the deployment.  
* In the "Outputs" section you will find the URL's and ports that you can use to connect to the F5 BIGIP cluster. 


### Deploy F5 Office 365 SAML Federation Solution in Azure ###
<a href="https://portal.azure.com/?pub_source=email&pub_status=success#create/f5-networks.f5-o365-federation-payg-previewf5-o365-fed-payg" target="_blank">
    <img src="http://azuredeploy.net/deploybutton.png"/>
</a>
