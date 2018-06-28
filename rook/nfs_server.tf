resource "google_compute_disk" "default" {
  name = "${var.disk}"
  type = "${var.raw_disk_type}"
  zone = "${var.gcp_zone}"
}

output "self_link_compute_disk" {
  value = "${google_compute_disk.default.self_link}"
}

data "template_file" "startup_script" {
  template = "${file("nfs_server_startup.sh")}"

  vars {
    device_name = "${var.device_name}"
    export_path = "${var.export_path}"
    vol_1       = "${var.vol_1}"
  }
}

resource "google_compute_instance" "nfs_server" {
  # project      = "${var.project}"
  # zone         = "${var.zone}"
  name = "tf-nfs-server"

  machine_type = "${var.nfs_machine_type}"

  boot_disk {
    initialize_params {
      image = "ubuntu-1604-xenial-v20170328"
    }
  }

  attached_disk {
    source      = "${google_compute_disk.default.name}"
    device_name = "${var.device_name}"
  }

  metadata_startup_script = "${data.template_file.startup_script.rendered}"
}

output "nfs_instance_id" {
  value = "${google_compute_instance.nfs_server.self_link}"
}

output "nfs_private_ip" {
  value = "${google_compute_instance.nfs_server.network_interface.0.address}"
}

output "nfs_public_ip" {
  value = "${google_compute_instance.nfs_server.network_interface.0.access_config.0.assigned_nat_ip}"
}
