resource "lab" "main" {
  title       = "task-3-shiv"
  description = "# Python Calculator Lab\n\n## What You Will Learn\n\nBy the end of this lab, you will be able to:\n\n- ✅ Verify a running Python Flask application from the terminal\n- ✅ Inspect Python app files and understand the project structure\n- ✅ Check if a Python process is running using `ps aux`\n- ✅ Read application logs to confirm a service started correctly\n- ✅ Test a web app endpoint using `curl` from the command line\n- ✅ Understand how a SQLite database stores data without any external DB\n- ✅ Navigate between a live web app tab and its history tab in Instruqt\n\n---\n\n## What Was Set Up For You\n\nWhen this lab started, the following happened automatically in the background:\n\n- **Ubuntu 22.04** VM was provisioned\n- **Python 3** and `pip` were installed\n- A **Python virtual environment** was created at `/root/.venv`\n- **Flask** was installed inside the virtual environment\n- The calculator app files were written to `/root/calculator/`\n- The Flask app was started and is now **running on port 8080**\n\n---\n\n## App File Structure\n\n```\n/root/calculator/\n├── app.py           ← Flask server (all routes)\n├── database.py      ← SQLite helper\n├── history.db       ← auto-created on first run\n└── templates/\n    ├── calc.html    ← Calculator UI\n    └── history.html ← History page\n```\n\n---\n\n## Tab Overview\n\n| Tab | What it shows |\n|-----|---------------|\n| **Calculator** | The live calculator web app |\n| **History** | All past calculations saved to SQLite |\n| **Terminal** | Shell access to the VM |\n| **Notes** | Quick reference for using the calculator |\n\n---\n\nClick **Next** to start verifying the setup.\n"

  layout = resource.layout.single_panel

  settings {
    theme = "modern-dark"

    timelimit {
      duration   = "30m"
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

  content {
    chapter "setup" {
      title = "Lab Setup"

      page "overview" {
        reference = resource.page.overview
      }

      page "verify" {
        reference = resource.page.verify
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
