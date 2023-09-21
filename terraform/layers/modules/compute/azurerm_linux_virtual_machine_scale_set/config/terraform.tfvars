#============================================================================#
#                                                                            #
#                       Date Created: 19/09/2023                             #
#                     Author: Sacha Roussakis-Notter                         #
#                                                                            #
# ===========================================================================#


main = {

    #######################################
    ## LINUX VIRTUAL MACHINES SCALE SETS ##
    #######################################

    linux_virtual_machine_scale_sets = {
        linux_scale_set_1 = {
            attach_public_ip = false
            use_ssh_authentication = true
            name = {
                purpose = "foo"
                identifier = "ubu"
            }
            settings = {
                instances = 1
                username = "adminuser"
                size = "Standard_D2_v3"
            }
            devops = {
                become_devops_agent = false
                devops_agent_name = "testAgent123"
                devops_agent_pool = "Self-Hosted-Agents"
            }
            tags = {
                owner = "Sacha1777@hotmail.com"
                role = "This virtual machine scale set is the default configuration settings for this module."
            }
        }
    }
}