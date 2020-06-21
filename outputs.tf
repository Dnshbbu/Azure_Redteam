output "csserver_vm_id"{
    value = "${azurerm_virtual_machine.DMZVMs.0.id}"
}

output "guacserver_vm_id"{
    value = "${azurerm_virtual_machine.DMZVMs.1.id}"
}
