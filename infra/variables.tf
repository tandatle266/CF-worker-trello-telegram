variable "cloudflare_api_token" {
  type        = string
  description = "CF API token with Workers + Zone DNS permissions"
  sensitive   = true
}
variable "cloudflare_account_id" {
  type        = string
  description = "Cloudflare Account ID"
}


variable "telegram_token" {
  type        = string
  sensitive   = true
}

variable "trello_key" {
  type        = string
  sensitive   = true
}

variable "trello_token" {
  type        = string
  sensitive   = true
}

variable "trello_list_id" {
  type = string
}
