import sqlite3
import sys
import datetime
import pathlib

def main() -> int:
    if len(sys.argv) < 3:
        print("usage: set_persona.py <db_path> <persona_md> [persona_id]")
        return 2
    db_path = sys.argv[1]
    persona_path = sys.argv[2]
    persona_id = sys.argv[3] if len(sys.argv) > 3 else "default"

    text = pathlib.Path(persona_path).read_text(encoding="utf-8").strip()
    if not text:
        print("ERROR persona file is empty")
        return 3

    now = datetime.datetime.now(datetime.timezone.utc).replace(tzinfo=None).isoformat(sep=" ", timespec="microseconds")
    con = sqlite3.connect(db_path)
    try:
        cur = con.cursor()
        tables = {r[0] for r in cur.execute("SELECT name FROM sqlite_master WHERE type='table'")}
        if "personas" not in tables:
            print("ERROR table personas not found; start AstrBot once first")
            return 4
        row = cur.execute("SELECT id FROM personas WHERE persona_id = ?", (persona_id,)).fetchone()
        if row:
            cur.execute(
                "UPDATE personas SET system_prompt = ?, updated_at = ? WHERE persona_id = ?",
                (text, now, persona_id),
            )
            action = "updated"
        else:
            cur.execute(
                "INSERT INTO personas (persona_id, system_prompt, begin_dialogs, tools, skills, custom_error_message, folder_id, sort_order, created_at, updated_at) "
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
                (persona_id, text, "[]", None, None, None, None, 0, now, now),
            )
            action = "inserted"
        con.commit()
        print(action + " persona_id=" + persona_id + " chars=" + str(len(text)))
        return 0
    finally:
        con.close()

if __name__ == "__main__":
    sys.exit(main())
