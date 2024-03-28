#Providers
terraform {
  required_providers {
    azurerm = {
      # Specify what version of the provider we are going to utilise
      source = "hashicorp/azurerm"
    }
    random = {
      source = "hashicorp/random"
    }
  }
}
provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}







