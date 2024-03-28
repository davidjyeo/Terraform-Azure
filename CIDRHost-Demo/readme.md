# Overview

This lab demonstrates the use of cidrhost Function within Terraform.

### ✅ With this function you can calculate a host IP address from a network prefix

In this example, the following Resources are created:

- VNETs and Subnets, the Count function is used in the Spoke Subnets to show how this Function works when using Count. Note: this is done using cidrsubnet, for which I have another Lab for in this Repo.
- DNS entries for the VNETs are set using cidrhost so you can control these automatically.
- A Network Interface Card in the Hub (using cidrhost)
- A Network Interface Card in the Hub (using cidrhost and join, along with the each.key option)
- A Network Security Group that makes use of cidrhost within two example rulesets - so this shows how you can use these dynamically within objects. (NSGs, DNS entries, Route Tables etc.)
- A Route Table that with two routes. One demonstrates cidrhost in it's pure form, the other is from the Spoke Subnet that makes use of the Count option.

## Using ```cidrhost```

⚠ Note: you'll need to customise this example and calculation for your needs, this just demonstrates the concept!

Within this demo environment, the following are created, based on a Single Azure Region. IP address spacing is as below:

- First Azure Region, assigned CIDR range ```10.x.0.0/19``` (for the whole Region)
- Each VNET uses ```/21``` (2046 addresses per VNET), ```10.x.0.0/21```
- The ```/24``` us used for each Subnet, giving simple easy to understand Subnets that provide ample room for Resources.

✅ The ```cidrsubnet``` function allows 1 variable in terraform.tfvars file, which specifies a range for the whole region!

### Setting DNS on the VNET

Setting DNS on the VNET you need two IP addresses, these would likely be assigned to a NVAs, Load Balancers or Domain Controllers. This is done usinf the ```cidrhost``` function to calculate the IPs. This allows the IPs to be set before the NICs are  created. In the case below, the VNET is ```10.x.0.0/21``` (calculated using cidrsubnet from the Regional Variable of ```10.x.0.0/19```).

```dns_servers = [cidrhost("${var.region1cidr}", 4), cidrhost("${var.region1cidr}", 5)]```

### Network Interface Card

The NICs are set in a similar way to the DNS entries above:

```private_ip_address = cidrhost("${var.region1cidr}", 4)```

### Network Interface Card - on a Subnet using Count

When using ```Count```, you cannot use the same method as above (all NICs would be assigned the same IP).  To overcome this add ```[count.index]``` and use ```join``` to combine the Subnet Range and the Host element together:

```private_ip_address = cidrhost(join(", ", "${azurerm_subnet.region1-spoke1-subnets[count.index].address_prefixes}"), 4)```

This allows ```cidrhost``` (in combination with ```join```) to increment the Private IP for each Resource created by ```Count``` (so it will increase the IP by 1 for each Resource created using ```Count```)

### Network Security Group

Within the Network Security Groups, we can use ```cidrhost``` easily within rules - simply by taking the relevant code item (e.g. to add a rule for a specific NIC, take the ```cidrhost``` block from the NICs private IP section):

```source_address_prefix = cidrhost("${var.region1cidr}", 4)```

Example when ```Count``` and ```Count Index``` have been used:

```source_address_prefix = cidrhost(join(", ", "${azurerm_subnet.region1-spoke1-subnets[0].address_prefixes}"), 4)```

### Route Table

Route Tables are similar to the NSG example, the interface addresses can be added in the same way:

```next_hop_in_ip_address = cidrhost("${var.region1cidr}", 4)```

 Example when ```Count``` and ```Count Index``` have been used:

```next_hop_in_ip_address = cidrhost(join(", ", "${azurerm_subnet.region1-spoke1-subnets[0].address_prefixes}"), 4)```
