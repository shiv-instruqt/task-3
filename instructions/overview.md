# Python Calculator Lab

## What Was Set Up For You

When this lab started, the following happened automatically in the background:

- **Ubuntu 22.04** VM was provisioned
- **Python 3** and `pip` were installed
- A **Python virtual environment** was created at `/root/.venv`
- **Flask** was installed inside the virtual environment
- The calculator app files were written to `/root/calculator/`
- The Flask app was started automatically and is now **running on port 8080**

---

## App File Structure

```
/root/calculator/
├── app.py          ← Flask server (all routes)
├── database.py     ← SQLite helper
├── history.db      ← auto-created on first run
└── templates/
    ├── calc.html   ← Calculator UI
    └── history.html ← History page
```

---

## What You Will Do

In the next page you will use the **Terminal** tab to:

1. Verify Python is installed and check its version
2. Confirm the Flask process is running
3. Inspect the app files
4. Check the Flask app log
5. Test the app directly with `curl`

---

## Tab Overview

| Tab | What it shows |
|-----|---------------|
| **Calculator** | The live calculator web app |
| **History** | All past calculations saved to SQLite |
| **Terminal** | Shell access to the VM |
| **Notes** | Quick reference for using the calculator |

Click **Next** to start verifying the setup.
