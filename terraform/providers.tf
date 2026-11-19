terraform {
  required_version = ">= 1.6.0"

  required_providers {
    genesyscloud = {
      source  = "MyPureCloud/genesyscloud"
      version = "~> 1.79"
    }
  }
}

provider "genesyscloud" {
  # Configure via GENESYSCLOUD_OAUTHCLIENT_ID, GENESYSCLOUD_OAUTHCLIENT_SECRET,
  # and GENESYSCLOUD_REGION environment variables in CI/CD or local shells.
}