# Step 3 — Check the History Tab

> 👉 **Switch to the History tab now.**

Every calculation you ran in the Calculator tab was automatically saved to a **SQLite database** (`history.db`) on the VM. The History tab is another **Service tab** pointing to the `/history` route.

---

## What You Should See

The History tab shows a table with:
- **#** — row ID from the SQLite database
- **Expression** — what you typed (e.g. `math.sqrt(144)`)
- **Result** — the computed answer (e.g. `12`)
- **Time** — when the calculation was run

---

## Verify the Database from the Terminal

Switch to the **Terminal tab** and run:

```bash
ls -lh /root/calculator/history.db
```
You should see the `.db` file with a non-zero size.

```bash
python3 -c "
import sqlite3
conn = sqlite3.connect('/root/calculator/history.db')
rows = conn.execute('SELECT * FROM history').fetchall()
for r in rows: print(r)
conn.close()
"
```
This prints every saved calculation directly from the SQLite database.

---

## What Is a Note Tab?

Look at the **Notes tab** on the right panel. It shows static markdown content — no server needed, no port, just a `.md` file referenced in `tabs.hcl`:

```hcl
resource "note" "notes" {
  file = "notes/notes.md"
}
```

This is useful for quick-reference docs, cheat sheets, or lab guides that learners can keep visible while working.

---

## Lab Complete ✅

You have now explored all 4 Instruqt tab types:

| Tab | Type | What you did |
|-----|------|--------------|
| **Terminal** | Terminal | Verified Python, Flask, files, logs, curl |
| **Calculator** | Service (`/`) | Ran live calculations via Flask |
| **History** | Service (`/history`) | Reviewed SQLite-backed calculation history |
| **Notes** | Note | Used as a static markdown reference panel |

> **Page 4 of 4** — Lab complete. Well done!
