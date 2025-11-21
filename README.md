# Telegram → Trello Bot (Cloudflare Worker + Terraform)

## Deploy
cd infra

touch terraform.tfvars
```
# Cloudflare credentials
cloudflare_api_token  = "sMKeXXXX"     # Cloudflare API Token
cloudflare_account_id = "74e9XXXX"     # Cloudflare Account ID

# Worker Subdomain (workers.dev)
workers_dev_subdomain = "dat-le2"      # Subdomain bạn thấy trong: <sub>.workers.dev

# Telegram bot
telegram_token = "82009XXXX"           # Telegram Bot Token

# Trello credentials
trello_key     = "167a3XXXX"           # Trello API Key
trello_token   = "ATTA37XXXX"          # Trello Token
trello_list_id = "68fa0XXXX"           # Trello List ID

```
terraform init
terraform apply -auto-approve
