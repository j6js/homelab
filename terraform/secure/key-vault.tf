resource "random_id" "vault_name" {
  byte_length = 4
}
resource "random_id" "key_name" {
  byte_length = 4
}
resource "azurerm_key_vault" "kv" {
  name                = "secure1-kv-${random_id.vault_name.hex}"
  location            = azurerm_resource_group.secure1-rg-nz.location
  resource_group_name = azurerm_resource_group.secure1-rg-nz.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  enabled_for_deployment = true
}
resource "azurerm_key_vault_key" "vault_key" {
  depends_on = [ azurerm_key_vault_access_policy.vault_access_policy, azurerm_key_vault_access_policy.vault_admin_access_policy ]
  name         = "secure1-kv-key-${random_id.key_name.hex}"
  key_vault_id = azurerm_key_vault.kv.id
  key_type     = "RSA"
  key_size     = 2048
  
  key_opts = [
    "wrapKey",
    "unwrapKey",
  ]
}
resource "azurerm_key_vault_access_policy" "vault_admin_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id
  application_id = data.azurerm_client_config.current.client_id

  key_permissions = [
    "Get",
    "List",
    "WrapKey",
    "UnwrapKey",
    "Create",
    "Delete",
    "GetRotationPolicy",
    "SetRotationPolicy",
    "Recover",
    "Purge"
  ]
}
resource "azurerm_key_vault_access_policy" "vault_access_policy" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id = azurerm_user_assigned_identity.secure1_vm_identity.tenant_id
  object_id    = azurerm_user_assigned_identity.secure1_vm_identity.principal_id
  key_permissions = [
    "Get",
    "WrapKey",
    "UnwrapKey"
  ]
}

# --- Azure Entra ID stuff ---
resource "azuread_application" "secure1_app" {
  display_name     = "secure1_vault"
  sign_in_audience = "AzureADMyOrg"
  required_resource_access {
    resource_app_id = "00000003-0000-0000-c000-000000000000" # Microsoft Graph API
    resource_access {
      id = "1bfefb4e-e0b5-418b-a88f-73c46d2cc8e9" # Application.ReadWrite.All
      type = "Role"
    }
    resource_access {
      id = "19dbc75e-c2e2-444c-a770-ec69d8559fc7" # Directory.ReadWrite.All
      type = "Role"
    }
    resource_access {
      id = "e1fe6dd8-ba31-4d61-89e7-88639da4683d" # User.Read
      type = "Scope"
    }
  }
}
resource "azurerm_user_assigned_identity" "secure1_vm_identity" {
  name                = "secure1-vm-identity"
  resource_group_name = azurerm_resource_group.secure1-rg-nz.name
  location            = azurerm_resource_group.secure1-rg-nz.location
}