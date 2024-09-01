resource "azurerm_resource_group" "submitter-function" {
  name     = "rg-${var.submitter_func_name}"
  location = var.location
}

resource "azurerm_service_plan" "submitter-function" {
  name                = "${var.submitter_func_name}-app-service-plan"
  resource_group_name = azurerm_resource_group.submitter-function.name
  location            = azurerm_resource_group.submitter-function.location
  os_type             = "Windows"
  sku_name            = "Y1"
}

resource "azurerm_storage_account" "submitter-function" {
  name                     = "str${replace(var.submitter_func_name, "-", "")}"
  resource_group_name      = azurerm_resource_group.submitter-function.name
  location                 = azurerm_resource_group.submitter-function.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_role_assignment" "sb-func-access-storage" {
  scope                 = azurerm_storage_account.submitter-function.id
  role_definition_name  = "Storage Blob Data Contributor"
  principal_id          = azurerm_windows_function_app.submitter-function.identity[0].principal_id
}

resource "azurerm_windows_function_app" "submitter-function" {
  name                = "${var.submitter_func_name}-app"
  resource_group_name = azurerm_resource_group.submitter-function.name
  location            = azurerm_resource_group.submitter-function.location
  service_plan_id            = azurerm_service_plan.submitter-function.id
  storage_account_name       = azurerm_storage_account.submitter-function.name
  storage_uses_managed_identity = true 

  identity {
    type = "SystemAssigned"
  }

  app_settings = {
  "WEBSITE_RUN_FROM_PACKAGE" = "1"
	"subscriptionId"    = var.subscription_id
	"resourceGroupName" = "rg-${var.quantum_workspace_name}"
	"workspaceName"     = "ws-${var.quantum_workspace_name}"
	"location"	        = var.location
  "target"            = var.target
  }
  
  site_config {
    application_stack {
      dotnet_version = "v8.0" 
      use_dotnet_isolated_runtime = true
    }
	use_32_bit_worker = false 
  }
}