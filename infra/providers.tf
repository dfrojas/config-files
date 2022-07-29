terraform {
  required_providers {
    namecheap = {
      source  = "namecheap/namecheap"
      version = ">= 2.0.0"
    }
  }
}

# Namecheap API credentials
provider "namecheap" {
  user_name   = "dfrojas"
  api_user    = "dfrojas"
  api_key     = var.namecheap_api_key
  client_ip   = var.ip
  use_sandbox = false
}
