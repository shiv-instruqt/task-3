# Step 1 — Verify the Setup

> 👉 **Open the Terminal tab now.**

Use the Terminal tab to run the commands below and confirm everything is working correctly.

---

## Check Python and the Virtual Environment

```bash
python3 --version
```
Expected: `Python 3.10.x`

```bash
ls /root/.venv/bin/python
```
Expected: `/root/.venv/bin/python`

```bash
/root/.venv/bin/pip show flask
```
Expected: Flask version info with `Name: Flask`.

---

## Check the App Files

```bash
ls -la /root/calculator/
```
You should see: `app.py`, `database.py`, `history.db`, `templates/`

```bash
ls -la /root/calculator/templates/
```
You should see: `calc.html`, `history.html`

---

## Confirm Flask is Running

```bash
ps aux | grep python
```
You should see a process with `/root/calculator/app.py` in the command.

```bash
cat /var/log/flask-app.log
```
Expected output includes: `Running on http://0.0.0.0:8080`

---

## Test the App with curl

```bash
curl -s http://localhost:8080/ | grep "<title>"
```
Expected: `<title>Calculator</title>`

```bash
curl -s http://localhost:8080/history | grep "<title>"
```
Expected: `<title>History</title>`

---

> **Page 2 of 4** — Flask is confirmed running. Click **Next** to open the Calculator tab and try it live.
