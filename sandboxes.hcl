resource "network" "network" {
  subnet = "10.100.100.0/24"
}

resource "container" "container-3" {
  network {
    id = resource.network.network.meta.id
  }
  image {
    name = "ubuntu:22.04"
  }
  port {
    local    = "8080"
    host     = "8080"
    protocol = "tcp"
  }
  privileged = false
  resources {
    cpu    = 1000
    memory = 512
  }
  run_as {
    user  = "root"
    group = "root"
  }
}

resource "exec" "setup_calculator" {
  target  = resource.container.container-3
  script  = "scripts/exec/setup_calculator/script.sh"
  timeout = "300s"

  environment = {
    DEBIAN_FRONTEND = "noninteractive"
    APP_DIR         = "/root/calculator"
    PORT            = "8080"
  }
}
