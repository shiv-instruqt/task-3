
resource "layout" "single_panel" {
  column {
    width = "50"
    tab "calculator" {
      title  = "calculator"
      target = resource.service.calculator
    }
    tab "history" {
      title  = "history"
      target = resource.service.history
    }
    tab "terminal" {
      title  = "terminal"
      target = resource.terminal.terminal
    }
  }
  column {
    width = "50"
    tab "notes" {
      title  = "notes"
      target = resource.note.notes
    }
    instructions {
      title = "Instructions"
    }
  }
}
