# Mock mode

This directory contains a lightweight mock setup for running the Hoot UI
without Firebase or network dependencies. Services are backed by in-memory
sample data.

## Run

```bash
flutter run -t mock/main.dart
```

The app will use the production UI from `lib/` but with static data, making it
useful for screenshots or UI experiments.
