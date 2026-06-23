resource "network" "main" {
  subnet = "10.0.200.0/24"
}

resource "vm" "ubuntu" {
  image {
    name = "ubuntu:22.04"
  }

  resources {
    cpu    = 2
    memory = 4096
  }

  environment = {
    DEBIAN_FRONTEND = "noninteractive"
  }

  startup_script = <<-EOF
    #!/bin/bash
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -y
    apt-get install -y python3 python3-pip python3-venv nano curl
    cd /root
    python3 -m venv .venv
    /root/.venv/bin/pip install flask
    mkdir -p /root/calculator/templates
    cat > /root/calculator/database.py << 'PYEOF'
import sqlite3, os
DB_PATH = os.path.join(os.path.dirname(os.path.abspath(__file__)), "history.db")

def init_db():
    conn = sqlite3.connect(DB_PATH)
    conn.execute("""CREATE TABLE IF NOT EXISTS history (
        id         INTEGER PRIMARY KEY AUTOINCREMENT,
        expression TEXT NOT NULL,
        result     TEXT NOT NULL,
        timestamp  DATETIME DEFAULT CURRENT_TIMESTAMP)""")
    conn.commit(); conn.close()

def save_calculation(expression, result):
    conn = sqlite3.connect(DB_PATH)
    conn.execute("INSERT INTO history (expression, result) VALUES (?, ?)", (expression, result))
    conn.commit(); conn.close()

def get_history():
    conn = sqlite3.connect(DB_PATH)
    rows = conn.execute("SELECT id, expression, result, timestamp FROM history ORDER BY id DESC LIMIT 50").fetchall()
    conn.close(); return rows

def clear_history():
    conn = sqlite3.connect(DB_PATH)
    conn.execute("DELETE FROM history")
    conn.commit(); conn.close()
PYEOF
    cat > /root/calculator/app.py << 'PYEOF'
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
        if not expr: return None, "Empty expression"
        for word in ["import","exec","eval","open","os","sys","__"]:
            if word in expr: return None, "Invalid expression"
        result = eval(expr, {"__builtins__": {}}, SAFE_NAMES)
        return result, None
    except ZeroDivisionError: return None, "Division by zero"
    except Exception as e:    return None, "Invalid: {}".format(str(e))

@app.route("/")
def calculator(): return render_template("calc.html")

@app.route("/calculate", methods=["POST"])
def calculate():
    data = request.get_json()
    result, error = safe_eval(data.get("expression", ""))
    if error: return jsonify({"error": error})
    display = "{:.10g}".format(result) if isinstance(result, float) else str(result)
    save_calculation(data.get("expression",""), display)
    return jsonify({"result": display})

@app.route("/history")
def history(): return render_template("history.html", history=get_history())

@app.route("/history/clear", methods=["POST"])
def clear(): clear_history(); return redirect(url_for("history"))

@app.route("/health")
def health(): return jsonify({"status": "ok"}), 200

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
PYEOF
    cat > /root/calculator/templates/calc.html << 'HTMLEOF'
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"/>
<title>Calculator</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{min-height:100vh;background:#0f0f13;display:flex;align-items:center;justify-content:center;font-family:'Courier New',monospace}
.wrap{width:340px}
h1{text-align:center;color:#7c6af7;font-size:1rem;letter-spacing:.3em;text-transform:uppercase;margin-bottom:20px;opacity:.8}
.calc{background:#1a1a24;border-radius:16px;padding:20px;box-shadow:0 20px 60px rgba(124,106,247,.15),0 0 0 1px rgba(124,106,247,.1)}
.display{background:#0f0f13;border-radius:10px;padding:16px 18px;margin-bottom:16px;min-height:80px;display:flex;flex-direction:column;justify-content:space-between;border:1px solid rgba(124,106,247,.15)}
.expr{color:#555570;font-size:.78rem;min-height:16px;word-break:break-all}
.result{color:#e8e8f0;font-size:2rem;font-weight:bold;text-align:right;word-break:break-all}
.result.error{color:#f76a6a;font-size:1rem}
.buttons{display:grid;grid-template-columns:repeat(4,1fr);gap:10px}
button{padding:16px 8px;border:none;border-radius:10px;font-size:1rem;font-family:'Courier New',monospace;cursor:pointer;font-weight:600}
.btn-num{background:#252535;color:#e8e8f0}.btn-op{background:#2a2040;color:#a99af5}
.btn-fn{background:#1e2535;color:#6ab5f7;font-size:.82rem}.btn-eq{background:#7c6af7;color:#fff;grid-column:span 2}
.btn-clear{background:#3a1f2a;color:#f76a6a}.btn-del{background:#2a2535;color:#f7a86a}
.history-link{display:block;text-align:center;margin-top:14px;color:#555570;font-size:.75rem;text-decoration:none}
</style></head><body>
<div class="wrap">
<h1>&#9670; Calc Lab</h1>
<div class="calc">
<div class="display"><div class="expr" id="expr"></div><div class="result" id="result">0</div></div>
<div class="buttons">
<button class="btn-fn" onclick="append('math.sqrt(')">&#8730;</button>
<button class="btn-fn" onclick="append('math.pow(')">x&#696;</button>
<button class="btn-fn" onclick="append('math.pi')">&#960;</button>
<button class="btn-clear" onclick="clearAll()">C</button>
<button class="btn-fn" onclick="append('math.sin(')">sin</button>
<button class="btn-fn" onclick="append('math.cos(')">cos</button>
<button class="btn-fn" onclick="append('math.tan(')">tan</button>
<button class="btn-del" onclick="deleteLast()">&#9003;</button>
<button class="btn-num" onclick="append('7')">7</button>
<button class="btn-num" onclick="append('8')">8</button>
<button class="btn-num" onclick="append('9')">9</button>
<button class="btn-op" onclick="append('/')">&#247;</button>
<button class="btn-num" onclick="append('4')">4</button>
<button class="btn-num" onclick="append('5')">5</button>
<button class="btn-num" onclick="append('6')">6</button>
<button class="btn-op" onclick="append('*')">&#215;</button>
<button class="btn-num" onclick="append('1')">1</button>
<button class="btn-num" onclick="append('2')">2</button>
<button class="btn-num" onclick="append('3')">3</button>
<button class="btn-op" onclick="append('-')">&#8722;</button>
<button class="btn-num" onclick="append('0')">0</button>
<button class="btn-num" onclick="append('.')">.</button>
<button class="btn-op" onclick="append('(')">( )</button>
<button class="btn-op" onclick="append('+')">+</button>
<button class="btn-eq" onclick="calculate()">=</button>
<button class="btn-fn" onclick="append('%')">mod</button>
<button class="btn-fn" onclick="append('abs(')">|x|</button>
</div></div>
<a href="/history" class="history-link">&#9656; View calculation history</a>
</div>
<script>
let expr="";
function append(val){
  if(val==="("){const o=(expr.match(/\(/g)||[]).length,c=(expr.match(/\)/g)||[]).length;expr+=o>c?")":"(";}
  else expr+=val;update();}
function clearAll(){expr="";document.getElementById("result").textContent="0";document.getElementById("result").className="result";update();}
function deleteLast(){expr=expr.slice(0,-1);update();}
function update(){document.getElementById("expr").textContent=expr;}
async function calculate(){
  if(!expr)return;
  const res=await fetch("/calculate",{method:"POST",headers:{"Content-Type":"application/json"},body:JSON.stringify({expression:expr})});
  const data=await res.json();const el=document.getElementById("result");
  if(data.error){el.textContent=data.error;el.className="result error";}
  else{el.textContent=data.result;el.className="result";expr=data.result;update();}}
document.addEventListener("keydown",e=>{
  if(e.key==="Enter")calculate();
  else if(e.key==="Backspace")deleteLast();
  else if(e.key==="Escape")clearAll();
  else if("0123456789.+-*/%()" .includes(e.key))append(e.key);});
</script></body></html>
HTMLEOF
    cat > /root/calculator/templates/history.html << 'HTMLEOF'
<!DOCTYPE html><html lang="en"><head><meta charset="UTF-8"/>
<title>History</title>
<style>
*{margin:0;padding:0;box-sizing:border-box}
body{min-height:100vh;background:#0f0f13;font-family:'Courier New',monospace;color:#e8e8f0;padding:30px 20px}
.container{max-width:680px;margin:0 auto}
.header{display:flex;align-items:center;justify-content:space-between;margin-bottom:24px}
h1{color:#7c6af7;font-size:.95rem;letter-spacing:.3em;text-transform:uppercase}
.back-link{color:#555570;text-decoration:none;font-size:.78rem}
.clear-btn{background:#3a1f2a;color:#f76a6a;border:none;border-radius:7px;padding:6px 14px;font-size:.75rem;font-family:'Courier New',monospace;cursor:pointer}
.empty{text-align:center;color:#333350;font-size:.9rem;margin-top:80px;line-height:2}
.count{font-size:.72rem;color:#444460;margin-bottom:14px}
table{width:100%;border-collapse:collapse}
thead th{text-align:left;font-size:.7rem;color:#444460;letter-spacing:.15em;text-transform:uppercase;padding:8px 12px;border-bottom:1px solid #1e1e2e}
tbody tr{border-bottom:1px solid #16161f}
td{padding:12px;font-size:.88rem}
td.id{color:#333350;font-size:.72rem;width:40px}td.expr{color:#a99af5;word-break:break-all}
td.result{color:#6af79a;font-weight:bold;text-align:right;width:130px}
td.time{color:#333350;font-size:.7rem;text-align:right;width:160px}
</style></head><body>
<div class="container">
<div class="header"><h1>&#9670; History</h1>
<div style="display:flex;gap:10px;align-items:center">
<a href="/" class="back-link">&#8592; Back</a>
{% if history %}
<form method="POST" action="/history/clear" onsubmit="return confirm('Clear all?')">
<button class="clear-btn" type="submit">Clear All</button></form>
{% endif %}</div></div>
{% if not history %}<div class="empty">No calculations yet.<br>Go run some numbers!</div>
{% else %}
<div class="count">{{ history|length }} calculation{{ 's' if history|length != 1 }}</div>
<table><thead><tr><th>#</th><th>Expression</th><th style="text-align:right">Result</th><th style="text-align:right">Time</th></tr></thead>
<tbody>{% for row in history %}<tr>
<td class="id">{{ row[0] }}</td><td class="expr">{{ row[1] }}</td>
<td class="result">{{ row[2] }}</td><td class="time">{{ row[3] }}</td>
</tr>{% endfor %}</tbody></table>
{% endif %}</div></body></html>
HTMLEOF
    nohup /root/.venv/bin/python /root/calculator/app.py > /var/log/flask-app.log 2>&1 &
    exit 0
  EOF

  port {
    local = 8080
    host  = 8080
  }

  network {
    id = resource.network.main.meta.id
  }
}
