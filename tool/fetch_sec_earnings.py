#!/usr/bin/env python3
"""Fills assets/earnings.json with the dates on which US companies published
their quarterly results, from SEC EDGAR (free, official).

A company announces its results in an 8-K filing whose "items" contain 2.02
(Results of Operations and Financial Condition). We keep the filing date.
EDGAR does not give the analysts' expectations: rows have no EPS fields, so
the game says "résultats publiés" without "meilleurs ou moins bons que prévu".

The SEC blocks requests that do not say who sends them. Give your contact:

    python3 tool/fetch_sec_earnings.py --contact "Prénom Nom prenom@example.com"

Rows of symbols not fetched (and rows that already have an EPS surprise, such
as Apple's) are kept untouched. Requests are spaced out: the SEC asks for at
most 10 per second.
"""
import argparse
import json
import subprocess
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent.parent
EARNINGS = ROOT / "assets" / "earnings.json"
CATALOG = ROOT / "assets" / "catalog.json"
SOURCE = "SEC EDGAR 8-K item 2.02"


def get_json(url: str, contact: str):
    # curl rather than urllib: python.org builds often lack CA certificates.
    out = subprocess.run(
        ["curl", "-sS", "-f", "-m", "60", "-A", contact, url],
        check=True, capture_output=True, text=True,
    ).stdout
    time.sleep(0.25)
    return json.loads(out)


def result_dates(filings: dict, since: str) -> set:
    """Filing dates of the 8-K that carry item 2.02."""
    dates = set()
    for form, day, items in zip(
        filings["form"], filings["filingDate"], filings["items"]
    ):
        if form == "8-K" and "2.02" in items.split(",") and day >= since:
            dates.add(day)
    return dates


def fetch_symbol(cik: int, since: str, contact: str) -> set:
    base = get_json(f"https://data.sec.gov/submissions/CIK{cik:010d}.json", contact)
    recent = base["filings"]["recent"]
    dates = result_dates(recent, since)
    # Older filings are in extra files, only needed if "recent" stops too late.
    if min(recent["filingDate"], default="9999") > since:
        for extra in base["filings"].get("files", []):
            if extra["filingTo"] < since:
                continue
            older = get_json(
                f"https://data.sec.gov/submissions/{extra['name']}", contact
            )
            dates |= result_dates(older, since)
    return dates


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--contact", required=True,
                        help='"Prénom Nom email": sent to the SEC as User-Agent')
    parser.add_argument("--since", default="2021-10-01")
    args = parser.parse_args()
    if "@" not in args.contact:
        parser.error("the contact must contain an e-mail address")

    catalog = json.loads(CATALOG.read_text())
    stocks = [c["symbol"] for c in catalog if c["type"] == "stock"]
    existing = json.loads(EARNINGS.read_text())
    # Symbols whose rows carry a real EPS surprise (Twelve Data) are kept.
    keep_symbols = {r["symbol"] for r in existing if r.get("surprise_prc") is not None}

    tickers = get_json("https://www.sec.gov/files/company_tickers.json", args.contact)
    cik_of = {t["ticker"]: t["cik_str"] for t in tickers.values()}

    rows = [r for r in existing if r["symbol"] in keep_symbols or r["symbol"] not in stocks]
    for symbol in stocks:
        if symbol in keep_symbols:
            print(f"{symbol}: kept (already has expectations)")
            continue
        cik = cik_of.get(symbol)
        if cik is None:
            print(f"{symbol}: not found at the SEC, skipped")
            continue
        dates = fetch_symbol(cik, args.since, args.contact)
        print(f"{symbol}: {len(dates)} announcements")
        # Tesla files an 8-K 2.02 in the first days of each quarter for its
        # vehicle deliveries: not its results, which come about three weeks later.
        if symbol == "TSLA":
            dates = {d for d in dates if int(d[8:]) > 5}
        rows += [{"symbol": symbol, "date": d, "source": SOURCE} for d in dates]

    rows.sort(key=lambda r: (r["symbol"], r["date"]), reverse=False)
    # Same layout as before: by symbol, newest first.
    rows.sort(key=lambda r: r["date"], reverse=True)
    rows.sort(key=lambda r: r["symbol"])
    EARNINGS.write_text(
        "[\n" + ",\n".join("  " + json.dumps(r, ensure_ascii=False) for r in rows) + "\n]\n"
    )
    print(f"{len(rows)} rows written to {EARNINGS.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
