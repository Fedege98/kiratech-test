# Configura il provider Azure
provider "azurerm" {
  features {}
  subscription_id = "your_subscription_id"
  client_id       = "your_client_id"
  client_secret   = "your_client_secret"
  tenant_id       = "your_tenant_id"
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
}

# Esegui i playbook Ansible per configurare il cluster Kubernetes
resource "null_resource" "ansible_provisioning" {
  # Utilizza gli ID delle istanze del cluster come trigger per eseguire il provisioning
  triggers = {
    cluster_instance_ids = "${join(",", azurerm_virtual_machine.master.*.id, azurerm_virtual_machine.worker.*.id)}"
  }

  # Esegui il playbook Ansible per tutti gli host
  provisioner "local-exec" {
    command = "ansible-playbook -i '${join(",", azurerm_virtual_machine.master.*.public_ip, azurerm_virtual_machine.worker.*.public_ip)},' all_host_playbook.yml"
  }

  # Esegui il playbook Ansible per i master
  provisioner "local-exec" {
    when    = "create"
    on_each = "master"
    command = "ansible-playbook -i '${azurerm_virtual_machine.master.*.public_ip},' master_playbook.yml"
  }

  # Esegui il playbook Ansible per i worker
  provisioner "local-exec" {
    when    = "create"
    on_each = "worker"
    command = "ansible-playbook -i '${azurerm_virtual_machine.worker.*.public_ip},' worker_playbook.yml"
  }
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
