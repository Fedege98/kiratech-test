# Configura il provider Azure
#link : https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs/guides/getting-started
provider "azurerm" {
  features {}
  subscription_id = "your_subscription_id"
  client_id       = "your_client_id"
  client_secret   = "your_client_secret"
  tenant_id       = "your_tenant_id"
}

# Configura il provider Kubernetes
#source: https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs
provider "kubernetes" {
  config_path = "~/.kube/config" # Dovrai puntare al tuo file di configurazione di Kubernetes
}

# Crea il namespace Kubernetes
resource "kubernetes_namespace" "kiratech-test" {
  metadata {
    name = "kiratech-test"
  }
}


# Crea le macchine virtuali per i master del cluster Kubernetes
#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/linux_virtual_machine.html
resource "azurerm_virtual_machine" "master" {
  count                            = 1
  name                             = "master"
  location                         = "West Europe"
  resource_group_name              = "your_resource_group"
  network_interface_id             = azurerm_network_interface.master[name].id
  vm_size                          = "Standard_F2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
    
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},' all_hosts_playbook.yml"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},' master_playbook.yml"
  }
}

# Crea le macchine virtuali per i worker del cluster Kubernetes
resource "azurerm_virtual_machine" "worker" {
  count                            = 2
  name                             = "worker${count.index}"
  location                         = "West Europe"
  resource_group_name              = "your_resource_group"
  network_interface_id             = azurerm_network_interface.worker[count.index].id
  vm_size                          = "Standard_F2"
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true
  
  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts"
    version   = "latest"
    }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},' all_hosts_playbook.yml"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},' worker_playbook.yml"
  }
}
