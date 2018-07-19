resource "kubernetes_replication_controller" "cloud-drupal" {
  metadata {
    name = "${var.gke_service_name}-repl-ctrlr"
  }

  spec {
    selector {
      app = "${var.gke_app_name}"
    }

    replicas = 1

    template {
      volume {
        name = "${kubernetes_persistent_volume.vol_1.metadata.0.name}"

        persistent_volume_claim {
          claim_name = "${kubernetes_persistent_volume_claim.pvc_1.metadata.0.name}"
        }
      }

      volume {
        name = "${kubernetes_secret.cloudsql-instance-credentials.metadata.0.name}"

        secret {
          secret_name = "${kubernetes_secret.cloudsql-instance-credentials.metadata.0.name}"
        }
      }

      volume {
        name = "${kubernetes_secret.cloudsql-db-credentials.metadata.0.name}"

        secret {
          secret_name = "${kubernetes_secret.cloudsql-db-credentials.metadata.0.name}"
        }
      }

      container {
        image = "${var.gke_drupal_image}"
        name  = "drupal"

        liveness_probe {
          http_get {
            port = 80
            path = "/"
          }

          initial_delay_seconds = 480
          timeout_seconds       = 3
        }

        volume_mount {
          name       = "${kubernetes_persistent_volume.vol_1.metadata.0.name}"
          mount_path = "${var.gke_nfs_mount_path}"
        }

        # volume_mount {
        #   name = "${kubernetes_secret.cloudsql-db-credentials.metadata.0.name}"
        #   mount_path = "/secrets/${kubernetes_secret.cloudsql-db-credentials.metadata.0.name}"
        # }


        # 
        # MARIADB_HOST=192.168.86.183 
        # MARIADB_ROOT_PASSWORD=pass
        # MYSQL_CLIENT_CREATE_DATABASE_NAME=bitnami_drupal -e 
        # MYSQL_CLIENT_CREATE_DATABASE_USER=bn_drupal 
        # MYSQL_CLIENT_CREATE_DATABASE_PASSWORD=password
        # DRUPAL_DATABASE_PASSWORD=password

        env = [
          {
            name  = "MARIADB_HOST"
            value = "127.0.0.1"
          },
          {
            # {
            #   name  = "MARIADB_PORT_NUMBER"
            #   value = "1234"
            # },
            name = "MARIADB_ROOT_USER"

            //value = "${var.cloudsql_username}"

            value = "${kubernetes_secret.cloudsql-db-credentials.data.username}"
          },
          {
            name = "MARIADB_ROOT_PASSWORD"

            //value = "${var.master_password}"

            value = "${kubernetes_secret.cloudsql-db-credentials.data.password}"
          },
          {
            name  = "MYSQL_CLIENT_CREATE_DATABASE_NAME"
            value = "bitnami_drupal"
          },
          {
            name  = "MYSQL_CLIENT_CREATE_DATABASE_USER"
            value = "${var.cloudsql_username}"
          },
          {
            name  = "MYSQL_CLIENT_CREATE_DATABASE_PASSWORD"
            value = "${kubernetes_secret.cloudsql-db-credentials.data.password}"
          },
          {
            name  = "WORDPRESS_DATABASE_PASSWORD"
            value = "BitnamiError"
          },
        ]

        # {
        #   name  = "DRUPAL_USERNAME"
        #   value = "${var.drupal_username}"
        # },
        # {
        #   name  = "DRUPAL_PASSWORD"
        #   value = "${var.drupal_password}"
        # },
        # {
        #   name  = "DRUPAL_EMAIL"
        #   value = "${var.drupal_email}"
        # },
      }

      container {
        image = "${var.gke_cloudsql_image}"
        name  = "cloudsql-proxy"

        command = [
          "/cloud_sql_proxy",
          "-instances=${google_sql_database_instance.master.connection_name}=tcp:3306",
          "-credential_file=/secrets/${kubernetes_secret.cloudsql-instance-credentials.metadata.0.name}/credentials.json",
        ]

        volume_mount {
          name       = "${kubernetes_secret.cloudsql-instance-credentials.metadata.0.name}"
          mount_path = "/secrets/${kubernetes_secret.cloudsql-instance-credentials.metadata.0.name}"
          read_only  = true
        }
      }
    }
  }
}

resource "kubernetes_service" "cloud-drupal" {
  metadata {
    name = "${var.gke_service_name}"
  }

  spec {
    selector {
      app = "${var.gke_app_name}"
    }

    type = "LoadBalancer"

    // not working:
    //load_balancer_ip = "${google_compute_address.frontend.0.address}"

    session_affinity = "ClientIP"
    port {
      protocol    = "TCP"
      port        = 80
      target_port = 80
    }
  }
}

output "lb_ip" {
  value = "${kubernetes_service.cloud-drupal.load_balancer_ingress.0.ip}"
}
