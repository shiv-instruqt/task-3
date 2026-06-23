resource "layout" "single_panel" {
  # Left column — app tabs (50%)
  column {
    width = "34"
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

  # Middle column — instructions (33%)
  column {
    width = "33"
    instructions {
      title  = "Instructions"
      active = true
    }
  }

  # Right column — notes (33%)
  column {
    width = "33"
    tab "notes" {
      title  = "notes"
      target = resource.note.notes
    }
  }
}
