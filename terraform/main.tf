locals {
  project_id = "<REPLACE ME WITH YOUR PROJECT ID>"

  region = "europe-west1"
  zone = "europe-west1-b"
  parsec_ingress_rule_name = "parsec-ingress"
  make_preemptible = false
}

provider "google" {
  credentials = file("./account.json")
  project     = local.project_id
  region      = local.region
}

data "google_compute_image" "windows_server_2022_desktop" {
  family  = "windows-2022"
  project = "windows-cloud"
}

resource "google_compute_instance" "parsec-1" {
  name             = "parsec-1"
  zone             = local.zone
  machine_type     = "n1-standard-8"
  min_cpu_platform = "Intel Skylake"
  tags = [
    "https-server",
    local.parsec_ingress_rule_name,
  ]

  boot_disk {
    initialize_params {
      image = data.google_compute_image.windows_server_2022_desktop.self_link
      size = 100
      type = "pd-ssd"
    }
  }

  guest_accelerator {
    // P100 with Virtual Workstation (NVIDIA GRID) enabled
    // https://cloud.google.com/compute/docs/gpus
    type = "nvidia-tesla-p100-vws"
    count = 1
  }
  enable_display = true

  network_interface {
    network = "default"

    access_config {
      // Ephemeral IP
    }
  }

  metadata = {
    enable-windows-ssh = "TRUE"
    sysprep-specialize-script-cmd = "googet -noconfirm=true install google-compute-engine-ssh"
  }

  scheduling {
    preemptible = local.make_preemptible
    automatic_restart = false
    on_host_maintenance = "TERMINATE"
  }
}

// https://support.parsecgaming.com/hc/en-us/articles/115002701631-Required-Dependencies-To-Set-Up-Your-Own-Cloud-Gaming-PC-Without-Parsec-Templates
resource "google_compute_firewall" "parsec-ingress" {
  name    = local.parsec_ingress_rule_name
  network = "default"

  // TODO: make this more secure by specifying only my IP
  source_ranges = ["0.0.0.0/0"]

  allow {
    protocol = "udp"
    ports    = ["8000-8011"]
  }

  target_tags = [local.parsec_ingress_rule_name]
}
