# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**OracleVault** is a local-first Flutter app for managing random tables, oracles, and drawable collections (Tarot decks, battlemaps, tokens, ambient sounds) for pen-&-paper and solo RPGs. It is explicitly a **data foundation**, not a play tool — rolling/generating/macros belong in downstream apps that consume the vault.

The detailed concept document is kept private and is **not** part of this public repository.

---

## Tech Stack

| Area | Choice |
|---|---|
| Framework | Flutter (Dart 3.x) |
| Database | Drift 2.x with FTS5 |
| State | Riverpod 2 with `@riverpod` codegen |
| Routing | go_router 14 with `StatefulShellRoute` |
| Media playback | media_kit |
| OCR | google_mlkit_text_recognition (local, offline) |
| Language detection | google_mlkit_language_id |
| Sharing | receive_sharing_intent + share_plus |
| Notifications | flutter_local_notifications + timezone |
| Server (Phase 8) | shelf (ported from PomTechFlow) |
| Auth (optional) | local_auth |

---

## Build Commands

No code exists yet — the project is in the concept phase. Once scaffolded:

```bash
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs  # Drift + Riverpod codegen
flutter run
flutter test
flutter test test/path/to/test_file.dart  # single test
```

**macOS CodeSign-Problem** (Projekt liegt im Documents-Ordner):
Finder/iCloud hängt `com.apple.FinderInfo` an das Bundle während es gebaut wird.
Zuverlässige Lösung — Frameworks einzeln signieren, dann App-Bundle:
```bash
flutter build macos --debug 2>/dev/null || true   # CodeSign schlägt fehl — Binary ist trotzdem da
APP=build/macos/Build/Products/Debug/oracle_vault.app
DEST=/tmp/ov_run.app
pkill -f oracle_vault 2>/dev/null; sleep 1
rm -rf "$DEST" && cp -r "$APP" "$DEST"
# Alle xattrs entfernen
find "$DEST" -exec xattr -c {} \; 2>/dev/null; true
# Frameworks vorab signieren
find "$DEST/Contents/Frameworks" -mindepth 1 -maxdepth 1 -type d | while read fw; do
  find "$fw" -name "*.dylib" -exec codesign --force -s - {} \; 2>/dev/null
  find "$fw" -maxdepth 3 -not -name "*.framework" -name "$(basename ${fw%.framework})" \
    -exec codesign --force -s - {} \; 2>/dev/null
  codesign --force --preserve-metadata=identifier -s - "$fw" 2>/dev/null
done
# App signieren (ohne --deep)
codesign --force -s - "$DEST/Contents/MacOS/oracle_vault"
codesign --force -s - "$DEST"
open "$DEST"
```

---

## Architecture

### Vault Format

A vault is a **plain folder** — portable, USB-friendly, no server required:

```
<vault>/
├── .oraclevault/
│   ├── index.db          # Drift DB (all tables + FTS5)
│   ├── thumbnails/       # Regenerable cache, excluded from backup
│   ├── backups/          # Auto-snapshots + daily backups
│   └── config.json       # Vault-specific settings
├── media/
│   ├── images/
│   ├── audio/
│   ├── video/
│   └── documents/
└── README.md
```

Multi-vault support (like Obsidian's vault picker) is a first-class feature. API keys are stored in `secure_storage`, never in the vault.

### Data Model

**Central idea:** everything is a Table — a d100 word list, a Tarot deck, a battlemap collection. All are a named set of entries with a draw mechanic.

Key entities:
- **Source** — provenance: book, URL, PDF, manual, or `ai_generation` (with full provider/model/prompt/seed JSON)
- **Table** — the oracle. Type: `uniform` | `weighted` | `dice` | `deck`
- **Entry** — a single row: short `content` text, optional `body_md` Markdown, weight, roll range, media ref, subtable ref
- **Media** — file asset with path, MIME, hash (deduplication)
- **Edge** — generic relation table (`from_type`/`from_id` → `to_type`/`to_id` + `relation`). Used instead of FK columns so any relation type is possible and backlinks come from a single query
- **SmartFilter** — saved filter as `{logic, rules}` JSON (same schema as MediaShelf — keep compatible)
- **WatchSource** / **InboxItem** — watcher config + staging for Reddit/RSS/folder items

All PKs are **UUIDs** (required for sync and bundle export).

**Multilingual tables** are separate entities linked via `Edge(relation='translation_of')` — no multi-lang columns.

**Wiki-links** (`[[Table]]`, `[[Table#Entry]]`, `![[img.png]]`) are written by the user in `content`/`body_md`. A save hook parses them and materialises Edge records. Raw text is preserved; edges are redundant but queryable.

### Roll Engine (`lib/core/roll_engine`)

Four modes: `uniform`, `weighted`, `dice` (custom `XdY+Z` parser, keep-highest/lowest), `deck` (draw without replacement, persistable hand state, Tarot reversed/upright modifier).

Recursive subtable resolution with cycle detection. The engine lives in the vault but is designed for direct import by downstream apps.

### Import Pipeline

Three stages: **Adapter → Normalise → Review/Commit**

- Each format has its own adapter implementing `Future<RawCandidate> parse(InputSource src)`
- Optional AI normalisation step (produces structured JSON, marks low-confidence entries with `confidence_low = true`)
- Single-pane review UI (no wizard): source view ↔ table editor, bidirectionally linked

### AI Provider Abstraction (`lib/core/llm`)

One OpenAI-compatible client with configurable `LLMProfile` objects (Ollama, LM Studio, OpenRouter all expose `/v1/`). Each task type (parsing, tag suggestion, generation, translation) maps to its own profile+model. No profiles shipped by default — user creates them.

AI-generated content always gets a `Source` of type `ai_generation` with `aiProviderJson` containing provider, model, version timestamp, prompts, params, and seed for reproducibility.

### UX Layout

- **Desktop:** 3-panel library (sidebar + list + detail preview), all panels collapsible
- **Mobile:** Bottom-Nav (Library / Inbox / Graph / More), FAB for import, filter chips instead of sidebar
- **Command Palette:** `Cmd+K`, searches tables/entries/actions/tags
- **Bulk edit:** hover marker (desktop) / long-press (mobile), shift-click range, per-field overwrite vs. append

---

## Phased Roadmap

Each phase delivers a runnable milestone. **Start with Phase 0.**

| Phase | Deliverable |
|---|---|
| 0 | Project scaffold, vault format, Drift schema (all entities, UUID PKs), backup system (auto + manual + JSON export), restore UI, multi-vault picker, roll engine |
| 1 | Manual table creation, 3-panel library, FTS5 search, tags/categories/sources UI, command palette, settings skeleton |
| 2 | Import pipeline (no AI): CSV/XLSX, MD/TXT, URL/HTML, PDF (text), ePub |
| 3 | AI provider abstraction, KI normalisation, tag/genre suggestions, table generation, auto-translation, AI source tracking |
| 4 | Full media entities, thumbnail pool (isolate), Tarot decks, battlemap/token collections, OCR |
| 5 | Wiki-link parser + autocomplete, edge materialisation, backlink panel, graph view |
| 6 | Watcher (Reddit/RSS/folder), inbox staging, grouped inbox UI, auto-approval |
| 7 | Mobile polish, share-sheet import, long-press bulk-edit, home widget |
| 8 | Server module from PomTechFlow (QR/mDNS pairing, UUID sync, conflict UI) |
| 9 | `.orcl` bundle export/import (ZIP with JSON + media) |

**Backup must be functional from Phase 0** — migrations must auto-snapshot before running.

---

## Reuse from Existing Projects

Do not reinvent these — port directly:

| From | What |
|---|---|
| BiNo | Riverpod + go_router + StatefulShellRoute app structure |
| BiNo | ML Kit OCR, sharing intent, flutter_local_notifications + timezone, local_auth, metadata_god |
| MediaShelf | `.vault/index.db` portable folder pattern |
| MediaShelf | Isolate thumbnailer pool |
| MediaShelf | SmartFilter `{logic, rules}` JSON schema (keep compatible) |
| MediaShelf | ResponsiveShell (desktop/mobile) |
| PomTechFlow | Server/client/standalone module with QR + mDNS pairing |
| PomTechFlow | JSON backup/restore pattern |
| PomTechFlow | Multi-platform CI via GitHub Actions |
| PomTechFlow | NavigationRail desktop/mobile logic |

---

## Out of Scope

These belong in **downstream RPG apps**, not in OracleVault:

- Dice rolling with history, macros, animations
- Scene/smart-trigger execution
- NSC generators, worldbuilding templates
- VTT functionality (token movement, initiative tracker)
- Character sheets, campaign management, combat tracker
