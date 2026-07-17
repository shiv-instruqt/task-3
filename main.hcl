resource "lab" "main" {
  title       = "task-3-shiv"
  description = ""

  layout = resource.layout.single_panel

  settings {
    theme = "modern-dark"

    timelimit {
      duration   = "30m"
      show_timer = true
    }

    idle {
      enabled      = true
      timeout      = "20m"
      show_warning = true
    }

    controls {
      show_stop = true
    }
  }

  content {
    chapter "setup" {
      title = "Lab Setup"

      page "overview" {
        reference = resource.page.overview
      }

      page "verify" {
        reference = resource.page.verify
      }

      page "use_calculator" {
        reference = resource.page.use_calculator
      }

      page "check_history" {
        reference = resource.page.check_history
      }
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

resource "page" "use_calculator" {
  title = "Use the Calculator Tab"
  file  = "instructions/use_calculator.md"
}

resource "page" "check_history" {
  title = "Check the History Tab"
  file  = "instructions/check_history.md"
}
