resource "azurerm_resource_group" "quantum-machine" {
  name     = "rg-${var.quantum_workspace_name}"
  location = var.location
}

resource "azurerm_storage_account" "quantum-machine" {
  name                     = "str${replace(var.quantum_workspace_name, "-", "")}"
  resource_group_name      = azurerm_resource_group.quantum-machine.name
  location                 = azurerm_resource_group.quantum-machine.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_role_assignment" "read-jobs" {
  scope                 = azurerm_storage_account.quantum-machine.id
  role_definition_name  = "Storage Blob Data Reader"
  principal_id          = azurerm_windows_function_app.retriever-function.identity[0].principal_id
}

resource "azurerm_role_assignment" "ws-access-storage" {
    scope                 = azurerm_storage_account.quantum-machine.id
    role_definition_name  = "Contributor"
    principal_id          = azapi_resource.quantum-machine.identity[0].principal_id
 }

resource "azurerm_role_assignment" "retriever-access-quantum-machine" {
  scope                 = azapi_resource.quantum-machine.id
  role_definition_name  = "Contributor"
  principal_id          = azurerm_windows_function_app.retriever-function.identity[0].principal_id
}

resource "azurerm_role_assignment" "submitter-access-quantum-machine" {
  scope                 = azapi_resource.quantum-machine.id
  role_definition_name  = "Contributor"
  principal_id          = azurerm_windows_function_app.submitter-function.identity[0].principal_id
}


resource "azapi_resource" "quantum-machine" {
  type = "microsoft.quantum/workspaces@2023-11-13-preview"
  name = "ws-${var.quantum_workspace_name}"
  location = var.location
  parent_id = azurerm_resource_group.quantum-machine.id
  identity {
    type =  "SystemAssigned"
  }
  body = jsonencode({
    properties = {
      providers = [
        {
          providerId = "ionq"
          providerSku = "aqt-pay-as-you-go-cred-new"
        },

      ]
      storageAccount = join("", ["/subscriptions/${var.subscription_id}/resourceGroups/",
      "${azurerm_resource_group.quantum-machine.name}/providers/Microsoft.Storage/",
      "storageAccounts/${azurerm_storage_account.quantum-machine.name}"])
    }
  })
}