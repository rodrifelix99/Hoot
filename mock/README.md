# UI mock

This directory provides a UI-only mock of Hoot. Pages under `mock/pages/`
use hardcoded data and manage their own state, allowing the interface to run
without any backend or GetX dependencies.

## Run

```bash
flutter run -t mock/main.dart
```

Launching with the entry point above starts the simplified mock app.
