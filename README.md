# SR Support Hub

Flutter support app for Sri Lanka Rent A Car representatives.

## Setup

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

## Environment

```bash
--dart-define=API_BASE_URL=https://your-api-domain.com/
--dart-define=WEBSOCKET_URL=wss://your-api-domain.com/ws/support
```

## Run

```bash
flutter run \
  --dart-define=API_BASE_URL=https://your-api-domain.com/ \
  --dart-define=WEBSOCKET_URL=wss://your-api-domain.com/ws/support
```

## Check quality

```bash
flutter analyze
flutter test
```

## Android builds

Debug APK:

```bash
flutter build apk --debug
```

Android App Bundle:

```bash
flutter build appbundle --release \
  --dart-define=API_BASE_URL=https://your-api-domain.com/ \
  --dart-define=WEBSOCKET_URL=wss://your-api-domain.com/ws/support
```

## Notes

- The current implementation uses mock repositories and static UI for the Phase 1–2 milestone.
- Later phases will replace the mock data layer with REST, WebSocket, Drift, and FCM integrations.
