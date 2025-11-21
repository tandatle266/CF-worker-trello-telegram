terraform {
  required_version = ">= 1.5"
  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "4.30.0"
    }
  }
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# ============================================
# Worker script
# ============================================
resource "cloudflare_worker_script" "telegram_trello_worker" {
  name          = "telegram-trello-worker"
  account_id    = var.cloudflare_account_id
  module = true  # 🚀 CHÌA KHÓA QUAN TRỌNG

  content = file("${path.module}/worker.js")

  # 🚀 BẮT BUỘC: bật ESM Worker
  compatibility_date  = "2024-01-01"
  compatibility_flags = ["nodejs_compat"]

  lifecycle {
    ignore_changes = [
      tags,
      compatibility_flags,
    ]
  }
}


# ============================================
# Worker Secrets
# ============================================
resource "cloudflare_worker_secret" "telegram_token" {
  account_id  = var.cloudflare_account_id
  script_name = cloudflare_worker_script.telegram_trello_worker.name
  name        = "TELEGRAM_TOKEN"
  secret_text = var.telegram_token
}

resource "cloudflare_worker_secret" "trello_key" {
  account_id  = var.cloudflare_account_id
  script_name = cloudflare_worker_script.telegram_trello_worker.name
  name        = "TRELLO_KEY"
  secret_text = var.trello_key
}

resource "cloudflare_worker_secret" "trello_token" {
  account_id  = var.cloudflare_account_id
  script_name = cloudflare_worker_script.telegram_trello_worker.name
  name        = "TRELLO_TOKEN"
  secret_text = var.trello_token
}

resource "cloudflare_worker_secret" "trello_list_id" {
  account_id  = var.cloudflare_account_id
  script_name = cloudflare_worker_script.telegram_trello_worker.name
  name        = "TRELLO_LIST_ID"
  secret_text = var.trello_list_id
}

# ============================================
# Auto Set Telegram Webhook → workers.dev
# ============================================
resource "null_resource" "set_webhook" {
  provisioner "local-exec" {
    command = <<EOT
curl -s -X POST \
"https://api.telegram.org/bot${var.telegram_token}/setWebhook?url=https://${cloudflare_worker_script.telegram_trello_worker.name}.${var.cloudflare_account_id}.workers.dev"
EOT
  }

  depends_on = [
    cloudflare_worker_script.telegram_trello_worker,
    cloudflare_worker_secret.telegram_token,
    cloudflare_worker_secret.trello_key,
    cloudflare_worker_secret.trello_token,
    cloudflare_worker_secret.trello_list_id
  ]
}

output "worker_webhook" {
  value = "https://${cloudflare_worker_script.telegram_trello_worker.name}.${var.cloudflare_account_id}.workers.dev"
}
