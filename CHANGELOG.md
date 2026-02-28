# Changelog

All notable changes to **DevPocket** are documented here.
Format follows [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [1.4.0] – 2026-03-01

### Added
- **Terminal (DevShell)**: Real Termux-like Android Linux terminal using `Process.start('sh', ['-c', cmd])`.
  - Live `stdout` / `stderr` streaming with color coding.
  - Real `cd` with persistent working directory tracking.
  - `Ctrl+C` kill button for running processes.
  - Command history (↑/↓ navigation).
  - Multi-session tabbed support.
  - Quick-command toolbar (`ls -la`, `ping`, `curl`, `df -h`, `ip addr`, etc.).
- **HTML Preview**: Response Viewer now renders HTML responses using `flutter_widget_from_html_core`.
  - JSON responses get pretty-printed with syntax color.
  - Fallback plain-text view with copy button for all other types.

### Fixed
- **API Tester Params/Headers Tab** — Completely replaced `DefaultTabController` + `TabBarView` with a custom `IndexedStack` approach, eliminating the internal `Material` white-background override.
- **HeadersEditor `LateInitializationError`** — Changed `late List` vars to eagerly-initialized lists with a `_controllersInitialized` boolean guard, fixing the silent crash that caused blank Params/Headers tabs.
- **HeadersEditor width** — Wrapped root column in `SizedBox(width: double.infinity)` to force full-width layout even when the pairs map is empty.

---

## [1.3.0] – 2026-02-28 — Postman-Level Pro Update

### Added
- **Tabbed Request Editor**: Horizontal tab bar (Params / Auth / Headers / Body) replacing vertical expandable sections.
- **Bi-directional URL & Params Sync**: Editing the URL updates the Params table and vice versa in real time.
- **Auth Engine**: Full Bearer token, Basic Auth, and API Key support. Postman collections with `auth` blocks are now parsed correctly.
- **Collection Runner v2**: Expandable result tiles showing full response body and headers per request.
- **"Clear Results" button** in Collection Runner.
- **Response Preview tab**: Renders HTML/JSON/text responses inline.
- **GitBook-style Documentation v2.0**: Chunked, searchable docs with deep linking.

### Changed
- API Tester layout refactored to high-density "Request Control Center".

### Fixed
- Build errors in `runner_screen.dart` (class nesting, orphaned methods, missing context refs).

---

## [1.2.6] – 2026-02 — Full HTTP Support

### Fixed
- Explicitly allowed cleartext HTTP traffic for Android and iOS release builds.
- Refined API Tester to allow intentional `http://` calls (httpbin, local servers).

---

## [1.2.5] – 2026-02 — Connectivity Fix

### Added
- Android permissions: `ACCESS_WIFI_STATE`, `CHANGE_WIFI_STATE`, `WIFI_LOCK`, `CHANGE_NETWORK_STATE`.

### Fixed
- Server Monitor background polling stability in release builds.

---

## [1.2.0] – 2026-02 — Ultimate UI & Polish

### Added
- **Shimmer Loading Skeletons**: Replaced spinners with glowing skeleton layouts.
- **Floating Animated Toasts**: Frosted-glass slide-down notifications.
- **Interactive Haptic Charts**: Touch-enabled sparklines with tooltips in Server Monitor.
- **Parallax Scroll Headers**: Large gradient headers that fold into the AppBar on scroll.
- **Dynamic Versioning**: Settings screen shows real version info.
- **Developer Connect**: GitHub profile link in Settings.

### Changed
- Theme engine fully refactored to `context.textStyles` extension for perfect Light/Dark contrast.

---

## [1.1.0] – 2026-01 — Advanced Pro Update

### Added
- **In-App Updates**: Automatic version checks via GitHub API with bottom-sheet prompt.
- **Collections Import / Export**: Backup and share workspaces as JSON.
- **Custom Branding**: Official logo and premium asset integration.

---

## [1.0.0] – Initial Release

- API Tester (REST client with collections).
- JWT Decoder & Generator.
- JSON Tools (format, diff, validate, query).
- Network Utilities (DNS, ping, SSL, HTTP headers).
- Encoders & Generators (Base64, URL, MD5, SHA, UUID, passwords).
- Regex Tester with live highlighting.
- Cron Parser with human-readable output.
- Server Monitor with uptime history.
- Reference Cheatsheets (HTTP codes, Git, Linux, TCP ports).
- Glassmorphism UI with Light / Dark / AMOLED Dark themes.
