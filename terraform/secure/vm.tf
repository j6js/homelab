resource "azurerm_linux_virtual_machine" "secure1-vm" {
  name                = "secure1-vm"
  resource_group_name = azurerm_resource_group.secure1-rg-nz.name
  location            = azurerm_resource_group.secure1-rg-nz.location
  size                = "Standard_F2ams_v6"
  priority = "Spot"
  eviction_policy = "Deallocate"

  disk_controller_type = "NVMe"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    disk_size_gb = 30
  }

  network_interface_ids = [
    azurerm_network_interface.secure1-nic.id,
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = data.sops_file.ssh_info.data["j6js.public_key"]
  }
  admin_username      = "azureuser"

  vtpm_enabled = true
  secure_boot_enabled = true
  encryption_at_host_enabled = true

  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }
  user_data = base64encode(templatefile("${abspath(path.module)}/cloud-init.yml", {
    vault_name = azurerm_key_vault.kv.name,
    vault_key_name = azurerm_key_vault_key.vault_key.name,
    vault_client_id = azuread_application.secure1_app.client_id,
    vault_client_secret = azuread_application_password.secure1_kv_client_secret.value,
    vault_tenant_id = data.azurerm_client_config.current.tenant_id,
    cf_account_id = data.sops_file.cloudflare.data["account_id"],
    cf_r2_access_key_id = data.sops_file.cloudflare.data["r2_access_key_id"],
    cf_r2_secret_key = data.sops_file.cloudflare.data["r2_secret_key"]
    cf_r2_bucket_name = cloudflare_r2_bucket.secure1_vault_bucket.name
    external_domain = data.sops_file.cloudflare.data["vault_domain"]
  }))
}