terraform{
    backend "azurerm"{
        resource_group_name  = "BradM_RG"
        storage_account_name = "testingstatefile "
        container_name       = "testfile"
        key                  = "hybrid_IaC"
    }
}