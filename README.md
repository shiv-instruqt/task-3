# Task 3 — Instruqt Lab: Python Calculator

> Instruqt 2.0 Lab demonstrating all 4 major tab types using a pure Python/SQLite calculator app.

## What This Lab Does

When a learner starts this lab, everything is **automatically set up** — no manual steps required. They simply interact with 4 tabs:

| Tab | Type | What the learner sees |
|---|---|---|
| **calculator** | Service (`/`) | Interactive calculator UI |
| **history** | Service (`/history`) | SQLite-backed calculation history |
| **terminal** | Terminal | Shell access to the container |
| **notes** | Note | How-to-use reference (markdown) |

---

## Repository Structure

```
task-3-shiv/
│
├── main.hcl                              # Lab resource definition
├── sandboxes.hcl                         # Container, network + exec setup
├── tabs.hcl                              # All 4 tab resources
├── layouts.hcl                           # 2-column layout definition
│
├── notes/
│   └── notes.md                          # Content for the Note tab
│
└── scripts/
    └── exec/
        └── setup_calculator/
            └── script.sh                 # Full automated setup script
```

---

## How the Automation Works

The `exec.setup_calculator` resource in `sandboxes.hcl` runs `scripts/exec/setup_calculator/script.sh` **inside** `container-3` before the learner gets access.

The script:
1. Installs `python3`, `pip`, and `flask` via `apt` + `pip3`
2. Writes all app files into `/root/calculator/` at runtime:
   - `database.py` — SQLite helper (auto-creates `history.db`)
   - `app.py` — Flask server with `/`, `/calculate`, `/history`, `/history/clear` routes
   - `templates/calc.html` — Calculator UI
   - `templates/history.html` — History page
3. Starts Flask as a **background daemon** on port `8080`
4. Polls `http://localhost:8080/` until it responds — setup only exits `0` when the app is live

---

## Tab Type Reference

| Tab | Instruqt Type | Docs Link |
|---|---|---|
| calculator | `resource "service"` | [Service Tabs](https://docs.instruqt.com) |
| history | `resource "service"` | [Service Tabs](https://docs.instruqt.com) |
| terminal | `resource "terminal"` | [Terminal Tabs](https://docs.instruqt.com) |
| notes | `resource "note"` | [Note Tabs](https://docs.instruqt.com) |

---

## Tech Stack

- **Runtime**: Ubuntu 22.04 container (no Docker-in-Docker)
- **Language**: Python 3 + Flask
- **Database**: SQLite (flat file, `history.db` — auto-created on first run)
- **Setup mechanism**: Instruqt `exec` resource → bash script

---

## Pushing to GitHub

```bash
git init
git add .
git commit -m "feat: task-3 calculator lab with 4 tab types"
git remote add origin <your-repo-url>
git push -u origin main
```
