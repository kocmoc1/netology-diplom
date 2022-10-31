resource "yandex_vpc_network" "prod_net" {
  name = "Prod-Net"
}

resource "yandex_vpc_subnet" "prod_subnet" {
  name           = "Prod-Subnet-0"
  zone           = var.yc_zone
  network_id     = "${yandex_vpc_network.prod_net.id}"
  v4_cidr_blocks = ["10.255.255.0/24"]
  route_table_id = "${yandex_vpc_route_table.route-for-prod.id}"
}

resource "yandex_vpc_subnet" "nat_subnet" {
  name           = "Nat-Subnet-0"
  zone           = var.yc_zone
  network_id     = "${yandex_vpc_network.prod_net.id}"
  v4_cidr_blocks = ["192.168.88.0/24"]
}


resource "yandex_vpc_address" "addr_cp" {
  name = "Control Plane Public IP"
  external_ipv4_address {
    zone_id = var.yc_zone
  }
}
resource "yandex_vpc_address" "addr_jenkins" {
  name = "Jenkins Public IP"
  external_ipv4_address {
    zone_id = var.yc_zone
  }
}
# resource "yandex_vpc_address" "addr_node1" {
#   name = "Worker Node1 Public IP"
#   external_ipv4_address {
#     zone_id = var.yc_zone
#   }
# }
# resource "yandex_vpc_address" "addr_node2" {
#   name = "Worker Node2 Public IP"
#   external_ipv4_address {
#     zone_id = var.yc_zone
#   }
# }
# resource "yandex_vpc_address" "addr_node3" {
#   name = "Worker Node3 Public IP"
#   external_ipv4_address {
#     zone_id = var.yc_zone
#   }
# }


resource "yandex_vpc_route_table" "route-for-prod" {
  network_id = "${yandex_vpc_network.prod_net.id}"

  static_route {
    destination_prefix = "0.0.0.0/0"
    next_hop_address   = yandex_compute_instance.nat-instance.network_interface.0.ip_address
  }
}

resource "yandex_compute_instance" "nat-instance" {
  name        = "nat-instance"
  folder_id = var.folder_id

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    initialize_params {
      image_id = "fd80mrhj8fl2oe87o4e1"
      size = 20
      type = "network-hdd"
    }
  }

  network_interface {
    subnet_id  = yandex_vpc_subnet.nat_subnet.id
    ip_address = "192.168.88.254"
    nat        = true
  }

  metadata = {
    user-data = file("cloud_config.yaml")
  }
}

resource "yandex_compute_instance" "prod_k8s_node0" {
  name = "prod-k8s-node0"
  folder_id = var.folder_id

  resources {
    cores  = 2
    core_fraction = 20
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.os_image_id
      size = 20
      type = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.prod_subnet.id
    ip_address = "10.255.255.20"
    # nat_ip_address = yandex_vpc_address.addr_cp.external_ipv4_address[0].address
    # nat       = true
  }

  metadata = {
    user-data = file("cloud_config.yaml")
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "prod_k8s_node1" {
  name = "prod-k8s-node1"
  folder_id = var.folder_id

  resources {
    cores  = 2
    core_fraction = 20
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.os_image_id
      size = 20
      type = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.prod_subnet.id
    ip_address = "10.255.255.21"
    #nat_ip_address = yandex_vpc_address.addr_node1.external_ipv4_address[0].address
    # nat       = true
  }

  metadata = {
    user-data = file("cloud_config.yaml")
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "prod_k8s_node2" {
  name = "prod-k8s-node2"
  folder_id = var.folder_id

  resources {
    cores  = 2
    core_fraction = 20
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.os_image_id
      size = 20
      type = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.prod_subnet.id
    ip_address = "10.255.255.22"
    #nat_ip_address = yandex_vpc_address.addr_node2.external_ipv4_address[0].address
    # nat       = true
  }

  metadata = {
    user-data = file("cloud_config.yaml")
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "prod_k8s_node3" {
  name = "prod-k8s-node3"
  folder_id = var.folder_id

  resources {
    cores  = 2
    core_fraction = 20
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = var.os_image_id
      size = 20
      type = "network-hdd"
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.prod_subnet.id
    ip_address = "10.255.255.23"
    #nat_ip_address = yandex_vpc_address.addr_node3.external_ipv4_address[0].address
    # nat       = true
  }

  metadata = {
    user-data = file("cloud_config.yaml")
  }

  scheduling_policy {
    preemptible = true
  }
}


resource "yandex_compute_instance" "prod_jenkins" {
  name = "prod-jenkins"
  folder_id = var.folder_id
  depends_on = [yandex_compute_instance.prod_k8s_node3, yandex_compute_instance.prod_k8s_node2,yandex_compute_instance.prod_k8s_node1,yandex_compute_instance.prod_k8s_node0]
  resources {
    cores  = 2
    core_fraction = 100
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id  = var.os_image_id
      size      = 20
      type      = "network-hdd"
    }
  }
  network_interface {
    subnet_id       = yandex_vpc_subnet.nat_subnet.id
    ip_address      = "192.168.88.253"
    nat_ip_address  = yandex_vpc_address.addr_jenkins.external_ipv4_address[0].address
    nat             = true
  }

  metadata = {
    user-data = file("cloud_config.yaml")
  }

  scheduling_policy {
    preemptible = true
  }
  provisioner "remote-exec" {
    inline = [
      "curl -o /tmp/install.sh https://storage.yandexcloud.net/devops-diplom-yandexcloud/install_jenkins.sh",
      "chmod 770 /tmp/install.sh",
      "bash /tmp/install.sh",
    ]
    connection {
      type = "ssh"
      user = "nposk"
      private_key = file("./.ssh/id_rsa")
      host = self.network_interface[0].nat_ip_address
    }
  }

}
