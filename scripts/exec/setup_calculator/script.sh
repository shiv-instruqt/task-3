#!/bin/bash
set -e

# ============================================================
# Instruqt 2.0 — Exec Setup Script
# Resource : exec.setup_calculator
# Target   : container.container-3 (ubuntu:22.04)
# Env vars : DEBIAN_FRONTEND, APP_DIR, PORT (set in sandboxes.hcl)
# ============================================================

APP_DIR="${APP_DIR:-/root/calculator}"
PORT="${PORT:-8080}"

# ------------------------------------------------------------
# 1. Install system dependencies
# ------------------------------------------------------------
echo ">>> apt-get update..."
apt-get update -y

echo ">>> Installing python3, pip, curl..."
apt-get install -y python3 python3-pip curl

echo ">>> Installing Flask via pip3..."
pip3 install flask

# ------------------------------------------------------------
# 2. Create directory structure
# ------------------------------------------------------------
echo ">>> Creating $APP_DIR/templates..."
mkdir -p "$APP_DIR/templates"

# ------------------------------------------------------------
# 3. Write database.py
# ------------------------------------------------------------
cat > "$APP_DIR/database.py" << 'PYEOF'
import sqlite3
import os

DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "history.db")

def init_db():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("""
        CREATE TABLE IF NOT EXISTS history (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            expression TEXT NOT NULL,
            result     TEXT NOT NULL,
            timestamp  DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    """)
    conn.commit()
    conn.close()

def save_calculation(expression, result):
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("INSERT INTO history (expression, result) VALUES (?, ?)", (expression, result))
    conn.commit()
    conn.close()

def get_history():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("SELECT id, expression, result, timestamp FROM history ORDER BY id DESC LIMIT 50")
    rows = c.fetchall()
    conn.close()
    return rows

def clear_history():
    conn = sqlite3.connect(DB_PATH)
    c = conn.cursor()
    c.execute("DELETE FROM history")
    conn.commit()
    conn.close()
PYEOF

# ------------------------------------------------------------
# 4. Write app.py
# ------------------------------------------------------------
cat > "$APP_DIR/app.py" << 'PYEOF'
from flask import Flask, render_template, request, jsonify, redirect, url_for
from database import init_db, save_calculation, get_history, clear_history
import math

app = Flask(__name__)
init_db()

SAFE_NAMES = {k: v for k, v in math.__dict__.items() if not k.startswith("__")}
SAFE_NAMES.update({"abs": abs, "round": round, "pow": pow})

def safe_eval(expression):
    try:
        expr = expression.strip()
        if not expr:
            return None, "Empty expression"
        blocked = ["import", "exec", "eval", "open", "os", "sys", "__"]
        for word in blocked:
            if word in expr:
                return None, "Invalid expression"
        result = eval(expr, {"__builtins__": {}}, SAFE_NAMES)
        return result, None
    except ZeroDivisionError:
        return None, "Division by zero"
    except Exception as e:
        return None, "Invalid expression: {}".format(str(e))

@app.route("/")
def calculator():
    return render_template("calc.html")

@app.route("/calculate", methods=["POST"])
def calculate():
    data = request.get_json()
    expression = data.get("expression", "")
    result, error = safe_eval(expression)
    if error:
        return jsonify({"error": error})
    display = "{:.10g}".format(result) if isinstance(result, float) else str(result)
    save_calculation(expression, display)
    return jsonify({"result": display})

@app.route("/history")
def history():
    rows = get_history()
    return render_template("history.html", history=rows)

@app.route("/history/clear", methods=["POST"])
def clear():
    clear_history()
    return redirect(url_for("history"))

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080, debug=False)
PYEOF

# ------------------------------------------------------------
# 5. Write templates/calc.html
# ------------------------------------------------------------
cat > "$APP_DIR/templates/calc.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Calculator</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      min-height: 100vh; background: #0f0f13;
      display: flex; align-items: center; justify-content: center;
      font-family: 'Courier New', monospace;
    }
    .wrap { width: 340px; }
    h1 {
      text-align: center; color: #7c6af7; font-size: 1rem;
      letter-spacing: 0.3em; text-transform: uppercase;
      margin-bottom: 20px; opacity: 0.8;
    }
    .calc {
      background: #1a1a24; border-radius: 16px; padding: 20px;
      box-shadow: 0 20px 60px rgba(124,106,247,0.15), 0 0 0 1px rgba(124,106,247,0.1);
    }
    .display {
      background: #0f0f13; border-radius: 10px; padding: 16px 18px;
      margin-bottom: 16px; min-height: 80px;
      display: flex; flex-direction: column; justify-content: space-between;
      border: 1px solid rgba(124,106,247,0.15);
    }
    .display .expr  { color: #555570; font-size: 0.78rem; min-height: 16px; word-break: break-all; }
    .display .result{ color: #e8e8f0; font-size: 2rem; font-weight: bold; text-align: right; word-break: break-all; }
    .display .result.error { color: #f76a6a; font-size: 1rem; }
    .buttons { display: grid; grid-template-columns: repeat(4, 1fr); gap: 10px; }
    button {
      padding: 16px 8px; border: none; border-radius: 10px;
      font-size: 1rem; font-family: 'Courier New', monospace;
      cursor: pointer; transition: all 0.12s ease; font-weight: 600;
    }
    button:active { transform: scale(0.94); }
    .btn-num   { background: #252535; color: #e8e8f0; }
    .btn-num:hover   { background: #2e2e45; }
    .btn-op    { background: #2a2040; color: #a99af5; }
    .btn-op:hover    { background: #352855; }
    .btn-fn    { background: #1e2535; color: #6ab5f7; font-size: 0.82rem; }
    .btn-fn:hover    { background: #253045; }
    .btn-eq    { background: #7c6af7; color: #fff; grid-column: span 2; }
    .btn-eq:hover    { background: #8f7fff; }
    .btn-clear { background: #3a1f2a; color: #f76a6a; }
    .btn-clear:hover { background: #4a2535; }
    .btn-del   { background: #2a2535; color: #f7a86a; }
    .btn-del:hover   { background: #352f45; }
    .history-link {
      display: block; text-align: center; margin-top: 14px;
      color: #555570; font-size: 0.75rem; letter-spacing: 0.1em;
      text-decoration: none; transition: color 0.2s;
    }
    .history-link:hover { color: #7c6af7; }
  </style>
</head>
<body>
  <div class="wrap">
    <h1>&#9670; Calc Lab</h1>
    <div class="calc">
      <div class="display">
        <div class="expr"   id="expr"></div>
        <div class="result" id="result">0</div>
      </div>
      <div class="buttons">
        <button class="btn-fn"    onclick="append('math.sqrt(')">&#8730;</button>
        <button class="btn-fn"    onclick="append('math.pow(')">x&#696;</button>
        <button class="btn-fn"    onclick="append('math.pi')">&#960;</button>
        <button class="btn-clear" onclick="clearAll()">C</button>
        <button class="btn-fn"    onclick="append('math.sin(')">sin</button>
        <button class="btn-fn"    onclick="append('math.cos(')">cos</button>
        <button class="btn-fn"    onclick="append('math.tan(')">tan</button>
        <button class="btn-del"   onclick="deleteLast()">&#9003;</button>
        <button class="btn-num"   onclick="append('7')">7</button>
        <button class="btn-num"   onclick="append('8')">8</button>
        <button class="btn-num"   onclick="append('9')">9</button>
        <button class="btn-op"    onclick="append('/')">&#247;</button>
        <button class="btn-num"   onclick="append('4')">4</button>
        <button class="btn-num"   onclick="append('5')">5</button>
        <button class="btn-num"   onclick="append('6')">6</button>
        <button class="btn-op"    onclick="append('*')">&#215;</button>
        <button class="btn-num"   onclick="append('1')">1</button>
        <button class="btn-num"   onclick="append('2')">2</button>
        <button class="btn-num"   onclick="append('3')">3</button>
        <button class="btn-op"    onclick="append('-')">&#8722;</button>
        <button class="btn-num"   onclick="append('0')">0</button>
        <button class="btn-num"   onclick="append('.')">.</button>
        <button class="btn-op"    onclick="append('(')">( )</button>
        <button class="btn-op"    onclick="append('+')">+</button>
        <button class="btn-eq"    onclick="calculate()">=</button>
        <button class="btn-fn"    onclick="append('%')">mod</button>
        <button class="btn-fn"    onclick="append('abs(')">|x|</button>
      </div>
    </div>
    <a href="/history" class="history-link">&#9656; View calculation history</a>
  </div>
  <script>
    let expr = "";
    function append(val) {
      if (val === "(") {
        const open  = (expr.match(/\(/g) || []).length;
        const close = (expr.match(/\)/g) || []).length;
        expr += open > close ? ")" : "(";
      } else { expr += val; }
      update();
    }
    function clearAll() {
      expr = "";
      document.getElementById("result").textContent = "0";
      document.getElementById("result").className = "result";
      update();
    }
    function deleteLast() { expr = expr.slice(0, -1); update(); }
    function update()     { document.getElementById("expr").textContent = expr; }
    async function calculate() {
      if (!expr) return;
      const res  = await fetch("/calculate", {
        method:  "POST",
        headers: { "Content-Type": "application/json" },
        body:    JSON.stringify({ expression: expr })
      });
      const data = await res.json();
      const el   = document.getElementById("result");
      if (data.error) {
        el.textContent = data.error;
        el.className   = "result error";
      } else {
        el.textContent = data.result;
        el.className   = "result";
        expr = data.result;
        update();
      }
    }
    document.addEventListener("keydown", (e) => {
      if      (e.key === "Enter")     calculate();
      else if (e.key === "Backspace") deleteLast();
      else if (e.key === "Escape")    clearAll();
      else if ("0123456789.+-*/%()" .includes(e.key)) append(e.key);
    });
  </script>
</body>
</html>
HTMLEOF

# ------------------------------------------------------------
# 6. Write templates/history.html
# ------------------------------------------------------------
cat > "$APP_DIR/templates/history.html" << 'HTMLEOF'
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="UTF-8"/>
  <meta name="viewport" content="width=device-width, initial-scale=1.0"/>
  <title>Calculation History</title>
  <style>
    * { margin: 0; padding: 0; box-sizing: border-box; }
    body {
      min-height: 100vh; background: #0f0f13;
      font-family: 'Courier New', monospace; color: #e8e8f0; padding: 30px 20px;
    }
    .container { max-width: 680px; margin: 0 auto; }
    .header {
      display: flex; align-items: center;
      justify-content: space-between; margin-bottom: 24px;
    }
    h1 { color: #7c6af7; font-size: 0.95rem; letter-spacing: 0.3em; text-transform: uppercase; }
    .actions { display: flex; gap: 10px; align-items: center; }
    .back-link {
      color: #555570; text-decoration: none;
      font-size: 0.78rem; letter-spacing: 0.1em; transition: color 0.2s;
    }
    .back-link:hover { color: #7c6af7; }
    .clear-btn {
      background: #3a1f2a; color: #f76a6a; border: none; border-radius: 7px;
      padding: 6px 14px; font-size: 0.75rem; font-family: 'Courier New', monospace;
      cursor: pointer; letter-spacing: 0.05em; transition: background 0.2s;
    }
    .clear-btn:hover { background: #4a2535; }
    .empty { text-align: center; color: #333350; font-size: 0.9rem; margin-top: 80px; line-height: 2; }
    .count { font-size: 0.72rem; color: #444460; margin-bottom: 14px; letter-spacing: 0.05em; }
    table { width: 100%; border-collapse: collapse; }
    thead th {
      text-align: left; font-size: 0.7rem; color: #444460;
      letter-spacing: 0.15em; text-transform: uppercase;
      padding: 8px 12px; border-bottom: 1px solid #1e1e2e;
    }
    tbody tr { border-bottom: 1px solid #16161f; transition: background 0.1s; }
    tbody tr:hover { background: #13131c; }
    td { padding: 12px; font-size: 0.88rem; vertical-align: middle; }
    td.id     { color: #333350; font-size: 0.72rem; width: 40px; }
    td.expr   { color: #a99af5; word-break: break-all; }
    td.result { color: #6af79a; font-weight: bold; text-align: right; width: 130px; }
    td.time   { color: #333350; font-size: 0.7rem; text-align: right; width: 160px; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>&#9670; History</h1>
      <div class="actions">
        <a href="/" class="back-link">&#8592; Back to Calc</a>
        {% if history %}
        <form method="POST" action="/history/clear" onsubmit="return confirm('Clear all history?')">
          <button class="clear-btn" type="submit">Clear All</button>
        </form>
        {% endif %}
      </div>
    </div>
    {% if not history %}
      <div class="empty">No calculations yet.<br>Go run some numbers!</div>
    {% else %}
      <div class="count">{{ history|length }} recent calculation{{ 's' if history|length != 1 }}</div>
      <table>
        <thead>
          <tr>
            <th>#</th>
            <th>Expression</th>
            <th style="text-align:right">Result</th>
            <th style="text-align:right">Time</th>
          </tr>
        </thead>
        <tbody>
          {% for row in history %}
          <tr>
            <td class="id">{{ row[0] }}</td>
            <td class="expr">{{ row[1] }}</td>
            <td class="result">{{ row[2] }}</td>
            <td class="time">{{ row[3] }}</td>
          </tr>
          {% endfor %}
        </tbody>
      </table>
    {% endif %}
  </div>
</body>
</html>
HTMLEOF

# ------------------------------------------------------------
# 7. Launch Flask as background daemon
#    Use 'set +e' around the background launch so the & does
#    not trigger an exit under set -e
# ------------------------------------------------------------
echo ">>> Starting Flask on port $PORT..."
cd "$APP_DIR"
set +e
nohup python3 app.py > /var/log/calculator.log 2>&1 &
FLASK_PID=$!
set -e
echo "Flask PID: $FLASK_PID"

# ------------------------------------------------------------
# 8. Wait up to 60s for Flask to respond on port 8080
# ------------------------------------------------------------
echo ">>> Waiting for Flask to be ready..."
READY=0
for i in $(seq 1 30); do
    if curl -sf "http://localhost:${PORT}/" > /dev/null 2>&1; then
        echo ">>> Flask is live on port $PORT (attempt $i)"
        READY=1
        break
    fi
    echo "  attempt $i/30 — retrying in 2s..."
    sleep 2
done

if [ "$READY" -eq 0 ]; then
    echo "ERROR: Flask did not start within 60 seconds. Log:"
    cat /var/log/calculator.log
    exit 1
fi

echo ">>> Flask confirmed live. Waiting 5s for proxy registration..."
sleep 5
echo ">>> Setup complete."
