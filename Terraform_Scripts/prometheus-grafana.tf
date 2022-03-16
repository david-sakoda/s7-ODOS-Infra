# kubectl port-forward --address 0.0.0.0 -n prometheus deploy/prometheus-server 8001:9090
# kubectl port-forward --address 0.0.0.0 -n grafana deploy/grafana 8001:3000

module "grafana_prometheus_monitoring" {
  source = "git::https://github.com/DNXLabs/terraform-aws-eks-grafana-prometheus.git"

  enabled = true

  settings_grafana  = {
    "adminPassword": var.grafana-pass,
    "persistence": {
        "enabled": true,
        "storageClassName": "gp2"
    }
  }

  settings_prometheus = {
    "alertmanager": {
        "persistentVolume": {
        "storageClass": "gp2"
        }
    },
    "server": {
        "persistentVolume": {
        "storageClass": "gp2"
        }
    }
    }
}