main = {

    #####################
    ## RESOURCE GROUPS ##
    #####################

    resource_groups = {
        example_1 = {
            enable_lock = false
            location = "australiaeast"
            purpose = "foo"
            identifier = "demo"
            tags = {
                owner = "sacha1777@hotmail.com"
                role = "This resource group is the default config for the module when it is not edited."
            }
        }
        
        example_2 = {
            enable_lock = false
            location = "australiaeast"
            purpose = "bar"
            identifier = "demo"
            tags = {
                owner = "sacha1777@hotmail.com"
                role = "This resource group is the default config for the module when it is not edited."
            }
        }
    }
}
