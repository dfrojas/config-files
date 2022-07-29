variable "namecheap_api_key" {
  description = "API Key of Namecheap"
  type        = string
  sensitive   = true
}

variable "ip" {
  description = "The IP from where we'll apply"
  type        = string
  sensitive   = true
}

variable "namecheap_txt_verification" {
  description = "TXT record for email verification"
  type        = string
  sensitive   = true
}
