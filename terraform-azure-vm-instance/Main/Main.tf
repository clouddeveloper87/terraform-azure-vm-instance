#Import Resource Group
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "3.52.0"
    }
  }
  required_version = ">=1.3.0"
}



data "azurerm_resource_group" "RG" {
  name = "HassanRG"
}

module "example_vnets" {
  source              = "../Modules/Vnet"
  resource_group_name = data.azurerm_resource_group.RG.name
  location            = "Southeast Asia"
  vnet_names          = ["vnet1"]
  address_spaces      = ["10.0.0.0/16"]
}

module "example_subnets" {
  source              = "../Modules/subnet"
  resource_group_name = data.azurerm_resource_group.RG.name
  vnet_name           = "vnet1"
  subnet_name        = "subnet1"
  address_prefixes    = ["10.0.1.0/24"]
}

# module "nic" {
#   source = "../Modules/nic"
#   nicname = "nic1"
#   location            = "Southeast Asia"
#   subnet_id           =    module.example_subnets.subnet_id
# }

# module "Webosvm" {
#   source       = "./vms"
#   rg_name      = module.rgnet.rg_name
#   agency       = var.agency
#   project_code = var.project_code
#   env          = var.env
#   zone         = var.zone
#   tier         = "web"
#   location     = var.location

#   #   purpose              = "os"
#   app_name  = var.web_vm_app_name
#   vm_size   = var.web_vm_size
#   subnet_id = module.sub_uat_web.subnet_id

#   hostname                        = var.web_hostname
#   admin_user                      = var.admin_user
#   admin_password                  = var.admin_password
#   asg_id                          = ""
#   user_data_base64                = ""
#   description                     = "Outsystems VM in App Compartment"
#   availability_zone               = var.availability_zone
#   boot_storage                    = module.storage_account.primary_blob_endpoint
#   nic                             = var.web_nic
#   data_disk                       = var.web_dd
#   data_disk_public_access_enabled = false
#   log_workspace_name              = module.log_analytics.log_analytics_workspace_name
#   mgmt_rg                         = module.rgnet.rg_name
#   backup_policy_id                = module.recovery.vm_backup_policy_id
#   recovery_vault_name             = module.recovery.recovery_vault_name
#   publisher                       = var.web_image_publisher
#   offer                           = var.web_image_offer
#   sku                             = var.web_image_sku
#   image_version                   = var.web_image_version

#   log_workspace_key           = ""
#   data_collection_rule_id     = [module.dcr.data_collection_rule_id]
#   data_collection_endpoint_id = module.mdce.id

#   log_workspace_id     = module.log_analytics.log_workspace_id
#   storage_account_logs = module.storage_account.id

#   os_disk_size = var.web_os_disk_size

#   # Auto shutdown
#   daily_recurrence_time = "1900"
#   timezone              = "Singapore Standard Time"

#   depends_on = [module.sub_uat_web]
# }
module "log_analytics" {
  source = "../Modules/loganalytic"
  
  location     = var.location
  rg_name      = data.azurerm_resource_group.RG.name

}

module "storage_account" {
  source       = "../Modules/Storage"

  location     = var.location
  rg_name          = data.azurerm_resource_group.RG.name
  log_workspace_id = module.log_analytics.log_workspace_id
}
# module "recovery" {
#   source       = "../Modules/recoveryservice"
#   location     = var.location
#   rg_name      = data.azurerm_resource_group.RG.name
#   log_workspace_id      = module.log_analytics.log_workspace_id
#   storage_account_logs  = module.storage_account.id
#   backup_starttime      = "14:00"
#   weekly_backup_copies  = 2
#   monthly_backup_copies = 1

#   # Enhanced
#   enhanced_backup_starttime      = "14:00"
#   enhanced_weekly_backup_copies  = 5
#   enhanced_monthly_backup_copies = 1
#   hour_interval                  = 4
#   hour_duration                  = 4
# }

# module "mdce" {
#   source       = "../Modules/datacollectionendpoint"
#    location     = var.location
#   rg_name      = data.azurerm_resource_group.RG.name
# }

# module "dcr" {
#   source           = "../Modules/datacollectionrule"
#   location     = var.location
  
  
#   rg_name          = data.azurerm_resource_group.RG.name
#   log_workspace_id = module.log_analytics.log_workspace_id
# }

module "vm" {
  source       = "../Modules/vm"
  rg_name      = data.azurerm_resource_group.RG.name
  # agency       = var.agency
  # project_code = var.project_code
  # env          = var.env
  # zone         = var.zone
  # tier         = "app"
  location     = var.location

  #   purpose              = "os"
  app_name  = var.app_vm_app_name
  vm_size   = var.app_vm_size
  subnet_id =  module.example_subnets.subnet_id[0] 

  hostname                        = var.app_hostname
  admin_user                      = var.admin_user
  admin_password                  = var.admin_password
  asg_id                          = ""
  user_data_base64                = ""
  description                     = "VM in the App Compartment"
  availability_zone               = var.availability_zone
  boot_storage                    = module.storage_account.primary_blob_endpoint
  nic                             = var.nicname
  data_disk                       = var.app_dd
  data_disk_public_access_enabled = false
 log_workspace_name              = module.log_analytics.log_analytics_workspace_name
#   mgmt_rg                         = data.azurerm_resource_group.RG.name
#  backup_policy_id                = module.recovery.vm_backup_policy_id
#   recovery_vault_name             = module.recovery.recovery_vault_name
  publisher                       = var.app_image_publisher
  offer                           = var.app_image_offer
  sku                             = var.app_image_sku
  image_version                   = var.app_image_version

  #  log_workspace_key           = ""
  #  data_collection_rule_id     = [module.dcr.data_collection_rule_id]
  #  data_collection_endpoint_id = module.mdce.id

   log_workspace_id     = module.log_analytics.log_workspace_id
   storage_account_logs = module.storage_account.id

  os_disk_size = var.app_os_disk_size

  # Auto shutdown
  daily_recurrence_time = "1900"
  timezone              = "Singapore Standard Time"

  depends_on = [module.example_subnets]
}

module "container" {
  source       = "../Modules/storagecontainer"
  rg_name          = data.azurerm_resource_group.RG.name
  sa_name = var.sa_name
  container_name ="coantain-vm"
}