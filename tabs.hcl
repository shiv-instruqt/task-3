resource "service" "calculator" {
  target = resource.container.container-3
  scheme = "http"
  port   = 8080
  path   = "/"
}

resource "service" "history" {
  target = resource.container.container-3
  scheme = "http"
  port   = 8080
  path   = "/history"
}

resource "terminal" "terminal" {
  target = resource.container.container-3
}

resource "note" "notes" {
  file = "notes/notes.md"
}
