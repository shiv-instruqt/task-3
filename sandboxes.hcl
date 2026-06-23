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

# Exec resource runs setup_calculator/script.sh inside the existing container.
# It installs Flask, writes all app files, and starts the Flask server as a
# background daemon — so all 4 tabs are live before the learner sees the lab.
resource "exec" "setup_calculator" {
  target  = resource.container.container-3
  script  = "scripts/exec/setup_calculator/script.sh"
  timeout = "300s"

  environment = {
    APP_DIR = "/root/calculator"
    PORT    = "8080"
  }
}
