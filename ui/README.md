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

The app signs in through `POST /api/auth/login/` using `contact_no` and stores the Django SimpleJWT `access` and `refresh` tokens.
