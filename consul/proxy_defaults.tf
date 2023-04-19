# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0


## Apply the configuration in main.tf before uncommenting and applying the configuration in this file.
/*
resource "kubernetes_manifest" "google_proxy_defaults" {
  provider = kubernetes.google
  manifest = {
    "apiVersion" = "consul.hashicorp.com/v1"
    "kind"       = "ProxyDefaults"
    "metadata" = {
      "name"       = "global"
      "namespace"  = "default"
      "finalizers" = ["finalizers.consul.hashicorp.com"]
    }
    "spec" = {
      "meshGateway" = {
        "mode" = "local"
      }
    }
  }
}
resource "kubernetes_manifest" "aks_proxy_defaults" {
  provider = kubernetes.aks
  manifest = {
    "apiVersion" = "consul.hashicorp.com/v1"
    "kind"       = "ProxyDefaults"
    "metadata" = {
      "name"       = "global"
      "namespace"  = "default"
      "finalizers" = ["finalizers.consul.hashicorp.com"]
    }
    "spec" = {
      "meshGateway" = {
        "mode" = "local"
      }
    }
  }
}
*/