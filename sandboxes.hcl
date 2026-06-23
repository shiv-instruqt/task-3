
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
    local    = "80"
    protocol = "tcp"
  }
  port {
    local    = "8080"
    protocol = "tcp"
  }
  privileged = false
  resources {
    cpu    = 1000
    memory = 256
  }
  run_as {
    user  = "root"
    group = "root"
  }
}
