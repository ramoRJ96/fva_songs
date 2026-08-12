#!/usr/bin/env python3
"""Parse Fihirana source text and import songs into Firestore."""

from __future__ import annotations

import json
import uuid
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path

PROJECT_ID = "fvasongs-d8055"
SOURCE = Path(__file__).with_name("fihirana_source.txt")
OUT_JSON = Path(__file__).with_name("songs_parsed.json")
FIREBASE_TOOLS_CONFIG = Path.home() / ".config/configstore/firebase-tools.json"

ACCENTS = {
    "à": "a",
    "â": "a",
    "ä": "a",
    "á": "a",
    "ã": "a",
    "å": "a",
    "è": "e",
    "ê": "e",
    "ë": "e",
    "é": "e",
    "ì": "i",
    "î": "i",
    "ï": "i",
    "í": "i",
    "ò": "o",
    "ô": "o",
    "ö": "o",
    "ó": "o",
    "õ": "o",
    "ù": "u",
    "û": "u",
    "ü": "u",
    "ú": "u",
    "ç": "c",
    "ñ": "n",
    "ÿ": "y",
    "’": "'",
    "‘": "'",
    "‛": "'",
}


def normalize(text: str) -> str:
    lower = text.lower().strip()
    return "".join(ACCENTS.get(ch, ch) for ch in lower)


def clean_line(line: str) -> str:
    line = line.replace("\t", " ")
    line = re.sub(r"[ \u00a0]+", " ", line).strip()
    return line


def letters_upper_ratio(text: str) -> float:
    letters = [c for c in text if c.isalpha()]
    if not letters:
        return 0.0
    return sum(1 for c in letters if c.isupper()) / len(letters)


HEADER_RE = re.compile(
    r"^(\d+)\s*(?:[\.\-]\s*|\s+)(.+)$"
)
VERSE_START_RE = re.compile(
    r"^(?:(\d+)\s*[\.\-]\s*|•\s*|-\s+)(.+)$"
)
REFRAIN_START_RE = re.compile(
    r"^(?:Ref\.?|Fiv\.?|Chorus|Refrain)\s*[:.\-]?\s*(.*)$",
    re.IGNORECASE,
)


def detect_song_starts(lines: list[str], body_offset: int) -> list[tuple[int, int, str]]:
    starts: list[tuple[int, int, str]] = []
    for i in range(body_offset, len(lines)):
        raw = clean_line(lines[i])
        if not raw:
            continue
        m = HEADER_RE.match(raw)
        if not m:
            continue
        number = int(m.group(1))
        title = clean_line(m.group(2))
        # Drop trailing page-like lonely digits sometimes glued
        title = re.sub(r"\s+\d{1,3}$", "", title).strip()
        if not title or number > 300:
            continue
        ratio = letters_upper_ratio(title)
        # Song titles are mostly uppercase; verses are mixed/lowercase.
        if ratio < 0.65:
            continue
        # Avoid mistaking "1. AFAKA AHO (2)" style repeated ALLCAPS short verse labels
        # that are still part of song 1 — those usually have few words and follow
        # immediately after another header with same song context. Keep if looks like title.
        starts.append((i, number, title))

    # Deduplicate consecutive identical (number, title)
    deduped: list[tuple[int, int, str]] = []
    for item in starts:
        if deduped and deduped[-1][1] == item[1] and deduped[-1][2] == item[2]:
            continue
        deduped.append(item)
    return deduped


def parse_sections(body_lines: list[str]) -> list[dict]:
    sections: list[dict] = []
    current: dict | None = None
    couplet_count = 0

    def flush() -> None:
        nonlocal current
        if current is None:
            return
        lines = [ln for ln in current["lines"] if ln.strip()]
        if lines:
            current["lines"] = lines
            sections.append(current)
        current = None

    def start_section(stype: str, index: int | None = None) -> None:
        nonlocal current, couplet_count
        flush()
        if stype == "couplet":
            couplet_count += 1
            index = index or couplet_count
        current = {
            "type": stype,
            "index": index,
            "lines": [],
            "isBis": False,
        }

    for raw in body_lines:
        line = clean_line(raw)
        if not line:
            continue

        ref = REFRAIN_START_RE.match(line)
        if ref:
            rest = clean_line(ref.group(1) or "")
            stype = "chorus" if line.lower().startswith("chorus") else "refrain"
            start_section(stype, None)
            if rest:
                current["lines"].append(rest)
            continue

        verse = VERSE_START_RE.match(line)
        if verse:
            num_s, rest = verse.group(1), clean_line(verse.group(2) or "")
            # If rest is empty, still start couplet
            index = int(num_s) if num_s else None
            # Heuristic: ALL-CAPS short "1. TITLE" already handled as song headers;
            # here inside body, numbered lines are couplets even if uppercase.
            start_section("couplet", index)
            if rest:
                current["lines"].append(rest)
            continue

        if current is None:
            start_section("couplet", None)
        assert current is not None
        current["lines"].append(line)

    flush()

    # If we only got one unlabeled couplet block with no structure, keep it.
    # Renumber couplets sequentially when missing indexes.
    couplet_i = 0
    for section in sections:
        if section["type"] == "couplet":
            couplet_i += 1
            if section.get("index") is None:
                section["index"] = couplet_i

    return sections


def first_line_of(sections: list[dict]) -> str:
    for section in sections:
        for line in section.get("lines", []):
            if line.strip():
                return line.strip()
    return ""


def build_search_text(song: dict) -> str:
    parts = [
        song["title"],
        song["number"],
        song.get("author", ""),
        song.get("theme", ""),
        song.get("key", ""),
        song.get("language", "mg"),
        song.get("firstLine", ""),
    ]
    for section in song.get("sections", []):
        parts.extend(section.get("lines", []))
    return normalize(" ".join(parts))


def parse_songs(text: str) -> list[dict]:
    lines = text.splitlines()
    # TOC ends at first body occurrence of song 1.
    body_offset = 0
    for i, line in enumerate(lines):
        if clean_line(line).upper() == "1. AFAKA NY GADRAKO" and i > 50:
            body_offset = i
            break

    starts = detect_song_starts(lines, body_offset)
    songs: list[dict] = []

    for idx, (start_i, number, title) in enumerate(starts):
        end_i = starts[idx + 1][0] if idx + 1 < len(starts) else len(lines)
        body = lines[start_i + 1 : end_i]
        sections = parse_sections(body)
        first = first_line_of(sections)
        song = {
            "title": re.sub(r"\s+", " ", title).strip(),
            "number": str(number),
            "author": "",
            "theme": "",
            "key": "",
            "language": "mg",
            "firstLine": first,
            "status": "approved",
            "sections": sections,
        }
        song["searchText"] = build_search_text(song)
        songs.append(song)

    return songs


def load_tokens() -> dict:
    data = json.loads(FIREBASE_TOOLS_CONFIG.read_text())
    tokens = data.get("tokens") or {}
    if not tokens.get("refresh_token"):
        raise RuntimeError("Aucun refresh_token Firebase CLI trouvé. Lancez `firebase login`.")
    return tokens


def refresh_access_token(refresh_token: str) -> str:
    # Public Firebase CLI OAuth client id
    client_id = "563584335869-fgrhgmd47bqnekij5i8b5pr03ho849e6.apps.googleusercontent.com"
    client_secret = "jEPSv-yUvl29Ow00RZOP6hg8"
    body = urllib.parse.urlencode(
        {
            "grant_type": "refresh_token",
            "refresh_token": refresh_token,
            "client_id": client_id,
            "client_secret": client_secret,
        }
    ).encode()
    req = urllib.request.Request(
        "https://oauth2.googleapis.com/token",
        data=body,
        headers={"Content-Type": "application/x-www-form-urlencoded"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        payload = json.loads(resp.read().decode())
    token = payload.get("access_token")
    if not token:
        raise RuntimeError(f"Échec refresh token: {payload}")
    return token


def fs_string(value: str) -> dict:
    return {"stringValue": value}


def fs_bool(value: bool) -> dict:
    return {"booleanValue": value}


def fs_int(value: int) -> dict:
    return {"integerValue": str(value)}


def fs_array(values: list[dict]) -> dict:
    return {"arrayValue": {"values": values}}


def fs_map(fields: dict) -> dict:
    return {"mapValue": {"fields": fields}}


def song_to_firestore_fields(song: dict, updated_at: str) -> dict:
    section_values = []
    for section in song["sections"]:
        fields = {
            "type": fs_string(section["type"]),
            "lines": fs_array([fs_string(line) for line in section["lines"]]),
            "isBis": fs_bool(bool(section.get("isBis", False))),
        }
        if section.get("index") is not None:
            fields["index"] = fs_int(int(section["index"]))
        section_values.append(fs_map(fields))

    return {
        "title": fs_string(song["title"]),
        "number": fs_string(song["number"]),
        "author": fs_string(song.get("author", "")),
        "theme": fs_string(song.get("theme", "")),
        "key": fs_string(song.get("key", "")),
        "language": fs_string(song.get("language", "mg")),
        "firstLine": fs_string(song.get("firstLine", "")),
        "status": fs_string(song.get("status", "approved")),
        "searchText": fs_string(song.get("searchText", "")),
        "sections": fs_array(section_values),
        "updatedAt": fs_string(updated_at),
        "source": fs_string("fihirana_import"),
    }



def get_api_key() -> str:
    gs = json.loads((Path(__file__).resolve().parents[1] / "android/app/google-services.json").read_text())
    return gs["client"][0]["api_key"][0]["current_key"]


def sign_in_anonymous(api_key: str) -> str:
    url = f"https://identitytoolkit.googleapis.com/v1/accounts:signUp?key={api_key}"
    body = json.dumps({"returnSecureToken": True}).encode()
    req = urllib.request.Request(
        url,
        data=body,
        headers={"Content-Type": "application/json"},
        method="POST",
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        payload = json.loads(resp.read().decode())
    token = payload.get("idToken")
    if not token:
        raise RuntimeError(f"Anonymous auth failed: {payload}")
    return token


def list_existing_imported(access_token: str) -> list[str]:
    """Return document names already imported from fihirana (best-effort)."""
    base = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents/songs"
    names: list[str] = []
    page_token = None
    while True:
        url = base + "?pageSize=300"
        if page_token:
            url += "&pageToken=" + urllib.parse.quote(page_token)
        req = urllib.request.Request(
            url,
            headers={"Authorization": f"Bearer {access_token}"},
        )
        with urllib.request.urlopen(req, timeout=60) as resp:
            payload = json.loads(resp.read().decode())
        for doc in payload.get("documents", []):
            fields = doc.get("fields", {})
            source = fields.get("source", {}).get("stringValue")
            if source == "fihirana_import":
                names.append(doc["name"])
        page_token = payload.get("nextPageToken")
        if not page_token:
            break
    return names


def delete_docs(access_token: str, names: list[str]) -> None:
    for i in range(0, len(names), 400):
        chunk = names[i : i + 400]
        writes = [{"delete": name} for name in chunk]
        body = json.dumps({"writes": writes}).encode()
        url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents:commit"
        req = urllib.request.Request(
            url,
            data=body,
            headers={
                "Authorization": f"Bearer {access_token}",
                "Content-Type": "application/json",
            },
            method="POST",
        )
        with urllib.request.urlopen(req, timeout=120) as resp:
            resp.read()


def import_songs(access_token: str, songs: list[dict], replace: bool = True) -> int:
    if replace:
        existing = list_existing_imported(access_token)
        if existing:
            print(f"Suppression de {len(existing)} anciens imports fihirana…")
            delete_docs(access_token, existing)

    updated_at = time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime())
    url = f"https://firestore.googleapis.com/v1/projects/{PROJECT_ID}/databases/(default)/documents:commit"
    imported = 0
    for i in range(0, len(songs), 25):
        chunk = songs[i : i + 25]
        writes = []
        for song in chunk:
            fields = song_to_firestore_fields(song, updated_at)
            doc_id = f"fihirana_{song['number']}_{uuid.uuid4().hex[:10]}"
            name = (
                f"projects/{PROJECT_ID}/databases/(default)/documents/songs/{doc_id}"
            )
            writes.append({"update": {"name": name, "fields": fields}})
        body = json.dumps({"writes": writes}).encode()
        req = urllib.request.Request(
            url,
            data=body,
            headers={
                "Authorization": f"Bearer {access_token}",
                "Content-Type": "application/json",
            },
            method="POST",
        )
        try:
            with urllib.request.urlopen(req, timeout=180) as resp:
                payload = json.loads(resp.read().decode())
        except urllib.error.HTTPError as exc:
            detail = exc.read().decode(errors="replace")
            raise RuntimeError(f"Firestore commit failed ({exc.code}): {detail}") from exc
        imported += len(payload.get("writeResults", []))
        print(f"Importé {imported}/{len(songs)}")
    return imported


def main() -> int:
    if not SOURCE.exists():
        print(f"Source manquante: {SOURCE}", file=sys.stderr)
        return 1

    text = SOURCE.read_text(encoding="utf-8")
    songs = parse_songs(text)
    OUT_JSON.write_text(json.dumps(songs, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Parsés: {len(songs)} chants → {OUT_JSON}")
    if songs:
        print(
            "Exemples:",
            ", ".join(f"{s['number']}. {s['title']}" for s in songs[:3]),
            "…",
            f"{songs[-1]['number']}. {songs[-1]['title']}",
        )
        empty = [s for s in songs if not s["sections"]]
        if empty:
            print(f"Attention: {len(empty)} chants sans sections")

    do_import = "--import" in sys.argv
    if not do_import:
        print("Ajoutez --import pour pousser vers Firestore.")
        return 0

    # Prefer Google OAuth (admin IAM); fallback to anonymous + temporary rules.
    access_token = None
    try:
        tokens = load_tokens()
        access_token = refresh_access_token(tokens["refresh_token"])
        print("Auth: Firebase CLI OAuth")
    except Exception as exc:
        print(f"OAuth indisponible ({exc}); bascule auth anonyme…")
        access_token = sign_in_anonymous(get_api_key())
        print("Auth: anonymous Firebase Auth")
    count = import_songs(access_token, songs, replace=True)
    print(f"Terminé: {count} documents écrits dans songs/")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
