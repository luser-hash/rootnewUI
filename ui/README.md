# Root Finance UI

Flutter frontend for the Root Finance Django API.

## Backend Integration

Start the backend from `D:\Root\Root\backend`:

```powershell
python manage.py runserver 0.0.0.0:8000
```

Default API URLs:

- Android emulator: `http://10.0.2.2:8000/api`
- Web/iOS/desktop: `http://localhost:8000/api`

Override the API URL when needed:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000/api
```

Build a release APK against the deployed Render backend:

```powershell
flutter build apk --release --dart-define=API_BASE_URL=https://rootbackenddeploy.onrender.com/api
```

## Android Release

The production Android application ID is `com.rootfinance.app`.

Create a local signing file from the checked-in template before building a production release:

```powershell
Copy-Item android/key.properties.example android/key.properties
```

Update `android/key.properties` with the release keystore path, alias, and passwords. The real `key.properties` and keystore files are ignored by Git.

CI can provide the same values through `ANDROID_STORE_FILE`, `ANDROID_STORE_PASSWORD`, `ANDROID_KEY_ALIAS`, and `ANDROID_KEY_PASSWORD`.

Generate a release keystore when you do not already have one:

```powershell
keytool -genkey -v -keystore android/release-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias root-finance-release
```

Run checks before release:

```powershell
flutter analyze
flutter test
```

The app signs in through `POST /api/auth/login/` using `contact_no` and stores the Django SimpleJWT `access` and `refresh` tokens.
