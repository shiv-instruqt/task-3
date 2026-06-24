# Step 2 — Use the Calculator Tab

> 👉 **Switch to the Calculator tab now.**

The Calculator tab is a **Service tab** — it exposes the Flask web app running on port 8080 directly inside the Instruqt interface.

---

## Try These Calculations

Use the buttons or type directly and press `Enter`:

**Basic arithmetic:**
```
25 * 4
```
Expected result: `100`

**Using a function:**
```
math.sqrt(144)
```
Expected result: `12`

**Power:**
```
math.pow(2, 10)
```
Expected result: `1024`

**Trig:**
```
math.sin(math.pi / 2)
```
Expected result: `1`

---

## What Is a Service Tab?

A **Service tab** in Instruqt creates an HTTP proxy that connects to a port inside your VM or container. In this lab:

- The Flask app runs on `0.0.0.0:8080` inside the VM
- The `port { local = 8080, host = 8080 }` block in `sandboxes.hcl` exposes it
- The `resource "service"` in `tabs.hcl` creates the tab proxy

This is how real-world web apps, dashboards, and APIs are exposed to learners in Instruqt labs.

---

> **Page 3 of 4** — Click **Next** to check the History tab and see how SQLite stores your calculations.
