resource "namecheap_domain_records" "dfrojas_verification" {
  domain = "dfrojas.com"
  mode   = "MERGE"

  record {
    hostname = "@"
    type     = "TXT"
    address  = var.namecheap_txt_verification
  }
}

resource "namecheap_domain_records" "dfrojas_email" {
  domain     = "dfrojas.com"
  email_type = "MX"
  mode       = "OVERWRITE"

  record {
    hostname = "@"
    type     = "MX"
    address  = "mx.zoho.com."
    mx_pref  = "10"
  }

  record {
    hostname = "@"
    type     = "MX"
    address  = "mx2.zoho.com."
    mx_pref  = "20"
  }

  record {
    hostname = "@"
    type     = "MX"
    address  = "mx3.zoho.com."
    mx_pref  = "50"
  }
}
