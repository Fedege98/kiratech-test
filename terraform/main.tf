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
provider "kubernetes" {
  config_path = "~/.kube/config"  # Dovrai puntare al tuo file di configurazione di Kubernetes
}

# Crea il namespace Kubernetes
resource "kubernetes_namespace" "kiratech-test" {
  metadata {
    name = "kiratech-test"
  }
}


# Crea le macchine virtuali per i master del cluster Kubernetes
resource "azurerm_virtual_machine" "master" {
  count                 = 1
  name                  = "master${count.index}"
  location              = "West Europe"
  resource_group_name   = "your_resource_group"
  network_interface_id  = azurerm_network_interface.master[count.index].id
  vm_size               = "Standard_D2s_v3"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true
  // Aggiungi qui la configurazione per il disco, l'immagine, ecc.

  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},' all_hosts_playbook.yml"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},' master_playbook.yml"
  }
}

# Crea le macchine virtuali per i worker del cluster Kubernetes
resource "azurerm_virtual_machine" "worker" {
  count                 = 2
  name                  = "worker${count.index}"
  location              = "West Europe"
  resource_group_name   = "your_resource_group"
  network_interface_id  = azurerm_network_interface.worker[count.index].id
  vm_size               = "Standard_D2s_v3"
  delete_os_disk_on_termination = true
  delete_data_disks_on_termination = true
  // Aggiungi qui la configurazione per il disco, l'immagine, ecc.

  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},' all_hosts_playbook.yml"
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i '${self.public_ip},' worker_playbook.yml"
  }
}
