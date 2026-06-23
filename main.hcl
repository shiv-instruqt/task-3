resource "lab" "main" {
  title       = "task-3-shiv"
  description = ""

  layout = resource.layout.single_panel

  settings {
    theme = "modern-dark"

    timelimit {
      duration   = "15m"
      show_timer = true
    }

    idle {
      enabled      = true
      timeout      = "5m"
      show_warning = true
    }

    controls {
      show_stop = true
    }
  }
}

resource "page" "overview" {
  title = "Lab Overview"
  file  = "instructions/overview.md"
}

resource "page" "verify" {
  title = "Verify the Setup"
  file  = "instructions/verify.md"
}
