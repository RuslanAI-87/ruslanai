from playwright.sync_api import sync_playwright
import openai
import os
import json
from bs4 import BeautifulSoup

openai.api_key = "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"

def analyze_url(url):
    try:
        with sync_playwright() as p:
            browser = p.chromium.launch()
            page = browser.new_page()
            page.goto(url)
            html = page.content()
            browser.close()
        soup = BeautifulSoup(html, "html.parser")
        h1 = [h.get_text(strip=True) for h in soup.find_all("h1")]
        h2 = [h.get_text(strip=True) for h in soup.find_all("h2")]
        h3 = [h.get_text(strip=True) for h in soup.find_all("h3")]
        title = soup.title.string.strip() if soup.title else ""
        meta = ""
        desc = soup.find("meta", attrs={"name": "description"})
        if desc and desc.get("content"):
            meta = desc["content"].strip()
        summary = f"Title: {title}\\nMeta: {meta}\\nH1: {h1}\\nH2: {h2}\\nH3: {h3}"
        prompt = f"""
You are a strategic SEO consultant with critical thinking. Analyze the HTML. List SEO issues with rationale and clear recommendations. Then evaluate the Google My Business presence (use web data if needed). Then list modern tools (2024–2025) other SEOs use for such projects. Finally, ask at least 3 intelligent follow-up questions.\n\nHTML:\n{summary}
"""
        response = openai.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[{"role": "user", "content": prompt}]
        )
        result = response.choices[0].message.content
        report = {
            "url": url,
            "title": title,
            "meta": meta,
            "h1": h1,
            "h2": h2,
            "h3": h3,
            "openai_response": result
        }
        site = url.split("//")[-1].split(".")[0]
        with open(f"C:/RuslanAI/reports/{site}.json", "w", encoding="utf-8") as f:
            json.dump(report, f, indent=2, ensure_ascii=False)
        return "OK"
    except Exception as e:
        return str(e)

if __name__ == "__main__":
    for url in ["https://lifegaines.com", "https://thrivex.com"]:
        analyze_url(url)

