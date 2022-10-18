terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "~> 4.0"
    }
  }
}

# Configure the GitHub Provider
provider "github" {
  #token = GITHUB_TOKEN
  owner = "jl-betriebssysteme"
}

variable "shared_repos" {
  type    = list(string)
  default = ["github-provisioner", "code-examples"]
}

variable "shared_secrets" {
  type = list(object({
    name   = string
    secret = string
  }))
  default = [{ name = "hello", secret = "abc" }, { name = "world", secret = "abc" }]
}

data "github_repository" "repo" {
  for_each = toset(var.shared_repos)
  name     = each.value
}


resource "github_actions_organization_secret" "example_secret" {
  secret_name     = "example_secret_name"
  visibility      = "private"
  plaintext_value = "private"
}

resource "github_actions_organization_secret" "example_secret_shared" {
  for_each = { for idx, val in var.shared_secrets : idx => val }
  #for_each                = toset(var.shared_secrets)
  secret_name             = each.value.name
  visibility              = "selected"
  plaintext_value         = each.value.secret
  selected_repository_ids = values(data.github_repository.repo)[*].repo_id
}
