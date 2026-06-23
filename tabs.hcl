resource "service" "calculator" {
  target = resource.vm.ubuntu
  scheme = "http"
  port   = 8080
  path   = "/"
}

resource "service" "history" {
  target = resource.vm.ubuntu
  scheme = "http"
  port   = 8080
  path   = "/history"
}

resource "terminal" "terminal" {
  target = resource.vm.ubuntu
  shell  = "/bin/bash"
}

resource "note" "notes" {
  file = "notes/notes.md"
}
