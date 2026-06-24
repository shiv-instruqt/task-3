# Python Calculator Lab

## What You Will Learn

By the end of this lab, you will be able to:

- ✅ Verify a running Python Flask application from the terminal
- ✅ Inspect Python app files and understand the project structure
- ✅ Check if a Python process is running using `ps aux`
- ✅ Read application logs to confirm a service started correctly
- ✅ Test a web app endpoint using `curl` from the command line
- ✅ Use a live web app served via a **Service tab** in Instruqt
- ✅ Understand how SQLite stores data without any external database

---

## What Was Set Up For You

When this lab started, the following happened automatically:

- **Ubuntu 22.04** VM was provisioned
- **Python 3** and `pip` were installed
- A **Python virtual environment** was created at `/root/.venv`
- **Flask** was installed inside the virtual environment
- The calculator app files were written to `/root/calculator/`
- The Flask app was started and is now **running on port 8080**

---

## App File Structure

```
/root/calculator/
├── app.py           ← Flask server (all routes)
├── database.py      ← SQLite helper
├── history.db       ← auto-created on first run
└── templates/
    ├── calc.html    ← Calculator UI
    └── history.html ← History page
```

---

## Your 4 Tabs

| Tab | Type | What it does |
|-----|------|--------------|
| **Calculator** | Service | Live calculator web app on port 8080 |
| **History** | Service | Past calculations saved to SQLite |
| **Terminal** | Terminal | Shell access to verify and inspect the VM |
| **Notes** | Note | Quick reference for calculator usage |

---

> **Page 1 of 4** — Click **Next** to open the Terminal tab and verify the setup.
