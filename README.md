# Vishwa Radio — mobile app

Flutter client for Vishwa Radio: live radio, video livestream, podcasts,
weekly timetable, about, contact and donate.

Content comes from the admin console's read-only API — the same endpoints the
website reads:

```
GET /api/public/site-settings
GET /api/public/schedule
GET /api/public/podcasts
GET /api/public/now-playing
x-api-key: <PUBLIC_API_KEY>
```

`PUBLIC_API_KEY` **is not a secret.** It ships inside the app binary, where
anyone can extract it. Treat it as a revocable handle: rotate it in both
projects to cut off old callers, which requires an app release. Nothing is
served from `/api/public` that isn't already published on the website.

## Status

Scaffold only. The screens, theme and services are described in:

- `../vishwa-radio-web/docs/superpowers/specs/2026-08-19-vishwa-radio-design.md`

## Getting started

```bash
flutter pub get
flutter run
```

## Identifiers

| | |
|---|---|
| Package | `vishwa_radio` |
| App ID | `com.vishwaradio.iddhidasanayaka` (Android and iOS, kept in step deliberately) |
