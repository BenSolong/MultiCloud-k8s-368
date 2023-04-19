# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

output "resource_group_name" {
  value = azurerm_resource_group.default.name
}

output "kubernetes_cluster_name" {
  value = azurerm_kubernetes_cluster.default.name
}

output "host" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.host
  sensitive = true
}
output "client_key" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.client_key
  sensitive = true
}

output "client_certificate" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.default.kube_config_raw
  sensitive = true
}

output "cluster_username" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.username
  sensitive = true
}

output "cluster_password" {
  value = azurerm_kubernetes_cluster.default.kube_config.0.password
  sensitive = true
}

resource "local_file" "kubeconfig" {
  depends_on = [azurerm_kubernetes_cluster.default]
  filename   = "kubeconfig"
  content    = azurerm_kubernetes_cluster.default.kube_config_raw
}