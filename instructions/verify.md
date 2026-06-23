# Verify the Setup

Use the **Terminal** tab to run each command below and confirm everything is working.

---

## Step 1 — Check Python Version

```bash
python3 --version
```

Expected output:
```
Python 3.10.x
```

---

## Step 2 — Check the Virtual Environment

```bash
ls /root/.venv/bin/python
```

Expected output:
```
/root/.venv/bin/python
```

---

## Step 3 — Confirm Flask is Installed

```bash
/root/.venv/bin/pip show flask
```

Expected output: Flask version info including `Name: Flask`.

---

## Step 4 — Check the App Files Exist

```bash
ls -la /root/calculator/
```

You should see `app.py`, `database.py`, `history.db`, and a `templates/` folder.

```bash
ls -la /root/calculator/templates/
```

You should see `calc.html` and `history.html`.

---

## Step 5 — Confirm Flask Process is Running

```bash
ps aux | grep python
```

You should see a line with `python /root/calculator/app.py` running.

---

## Step 6 — Check the Flask Log

```bash
cat /var/log/flask-app.log
```

Expected output:
```
* Running on http://0.0.0.0:8080
```

---

## Step 7 — Test the App with curl

```bash
curl -s http://localhost:8080/ | grep "<title>"
```

Expected output:
```html
<title>Calculator</title>
```

```bash
curl -s http://localhost:8080/history | grep "<title>"
```

Expected output:
```html
<title>History</title>
```

---

## Step 8 — View the App Live

Switch to the **Calculator** tab to see the app running in your browser.
Try a calculation — then switch to the **History** tab to see it saved.
