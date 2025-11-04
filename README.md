# 🌐 OneClick Flutter SDK

Unified Flutter SDK for integrating **iOS** and **Android** one-click login services.

---

### 📦 Installation

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  oneclick:
    git:
      url: https://github.com/datashield-ltd/oneclick.git
```

Then run:

```bash
flutter pub get
```

---

### ⚙️ Initialization

Before using the SDK, you must initialize it:

```dart
await Oneclick.initialize(
  token: "YOUR_TOKEN",
  ak: "YOUR_ACCESS_KEY",
  sk: "YOUR_SECRET_KEY",
);
await Oneclick.setLogo("ic_launcher");
await Oneclick.setLanguage("en");
```

---

### ✅ Check Support

After initialization, check if the current device supports one-click login:

```dart
bool supported = await Oneclick.isSupport();
if (supported) {
  print("✅ One-click login supported");
} else {
  print("❌ Not supported");
}
```

---

### 🚀 Start Login

Call `showLogin()` to initiate one-click login:

```dart
final result = await Oneclick.showLogin();

if (result["success"] == true) {
  print("✅ Login successful");
} else {
  print("❌ Login failed: ${result["message"]}");
}
```

---

### 🔄 Listen for Login Events

Use `Oneclick.onLoginResult` to listen for native login results:


```dart
Android：
success：
{
"type": "login_success",
"success": true,
"token": "token",
"phone_number": "phoneNumber"
}

failure:
{
"type": "login_failure",
"success": false,
"code": "code"
}

IOS：
success：
{
"success": true,
"token": "token",
"phone_number": "phoneNumber"
}

failure:
{
"success": false,
"code": "code" ,
"message": "message" ,
}

subscription = Oneclick.onLoginResult.listen((event) {
if (event["type"] == "login_success" && event["success"] == true) {
// Android login success
setState(() {
_result = "✅ Login successful\n📱 Phone number: ${event["phone_number"] ?? ''}\n🔑 Token: ${event["token"] ?? ''}";
});
} else if (event["type"] == "login_failure" && event["success"] == false) {
// Android login failure
final errorCode = event["code"] ?? 'UNKNOWN_ERROR';
} else if (event["success"] == true && !event.containsKey("type")) {
// iOS login success (no type field)
setState(() {
_result = "✅ Login successful\n📱 Phone number: ${event["phone_number"] ?? ''}\n🔑 Token: ${event["token"] ?? ''}";
});
} else if (event["success"] == false && !event.containsKey("type")) {
// iOS login failure
final errorCode = event["code"] ?? 'UNKNOWN_ERROR';
}
}, onError: (error) {
print("❌ Error: $error");
});
```

---

### 🧹 Dispose

When done, release resources:

```dart
Oneclick.instance.dispose();
```

---

### 🧪 Example Project

The repository includes a full demo in `example/lib/main.dart`:

```bash
flutter run example
```

---

### 📱 Supported Platforms

| Platform | Support |
|-----------|----------|
| Android   | ✅ Yes |
| iOS       | ✅ Yes |
| Web       | ❌ No |
| macOS / Windows / Linux | ❌ No |

---

### 🧰 Native SDK Requirements

#### Android
- Requires proper integration of native Android SDK
- Add permissions to `AndroidManifest.xml`:
  ```xml
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_WIFI_STATE" />
    <uses-permission android:name="android.permission.CHANGE_NETWORK_STATE" />
  ```

#### iOS
- Requires native iOS SDK integration
- Make sure `Bundle ID`, `Token`, `AK`, and `SK` are valid
