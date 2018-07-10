resource "google_compute_disk" "default" {
  name = "${var.nfs_disk_name}"
  type = "${var.nfs_raw_disk_type}"
  zone = "${var.gcp_zone}"
}

output "self_link_compute_disk" {
  value = "${google_compute_disk.default.self_link}"
}

//simple instance with startup script
resource "google_compute_instance" "nfs_server" {
  zone = "${var.gcp_zone}"
  name = "${var.nfs_server_name}"

  machine_type = "${var.nfs_machine_type}"

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170328"
    }
  }

  network_interface {
    network = "default"
  }

  attached_disk {
    source      = "${google_compute_disk.default.name}"
    device_name = "${var.nfs_disk_name}"
  }

  metadata_startup_script = "${file("nfs_flight.sh")}"
}

output "nfs_instance_id" {
  value = "${google_compute_instance.nfs_server.self_link}"
}

output "nfs_private_ip" {
  value = "${google_compute_instance.nfs_server.network_interface.0.address}"
}

# output "nfs_public_ip" {
#   value = "${google_compute_instance.nfs_server.network_interface.0.access_config.0.assigned_nat_ip}"
# }

