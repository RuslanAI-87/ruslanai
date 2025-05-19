import os
import json
from pathlib import Path
from datetime import datetime

MEMORY_DIR = Path("C:/RuslanAI/memory/seo_analyst")
MEMORY_FILE = MEMORY_DIR / "memory.json"

class SEOMemory:
    def __init__(self):
        MEMORY_DIR.mkdir(parents=True, exist_ok=True)
        if not MEMORY_FILE.exists():
            with open(MEMORY_FILE, "w", encoding="utf-8") as f:
                json.dump([], f)

    def _load(self):
        with open(MEMORY_FILE, "r", encoding="utf-8") as f:
            return json.load(f)

    def _save(self, data):
        with open(MEMORY_FILE, "w", encoding="utf-8") as f:
            json.dump(data, f, indent=2, ensure_ascii=False)

    def add(self, content: str, source: str):
        data = self._load()
        record = {
            "timestamp": datetime.utcnow().isoformat(),
            "source": source,
            "content": content
        }
        data.append(record)
        self._save(data)

    def get(self, keyword: str):
        data = self._load()
        return [r for r in data if keyword.lower() in r["content"].lower() or keyword.lower() in r["source"].lower()]

    def summary(self):
        data = self._load()
        return [
            {
                "source": r["source"],
                "time": r["timestamp"],
                "preview": r["content"][:150] + "..." if len(r["content"]) > 150 else r["content"]
            } for r in data
        ]

if __name__ == "__main__":
    mem = SEOMemory()
    mem.add("?????? ??????? ????? lifegaines.com: H1, H2 ???????, title ?????????????.", "lifegaines.com")
    print(mem.summary())
