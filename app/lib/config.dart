// Set your laptop's LAN IP here, or override at run time:
//   fvm flutter run --dart-define=API=http://192.168.1.20:8000
// Backend base URL. Mutable so the Advanced/Dev panel can repoint it at runtime
// (persisted in Meta, loaded at startup); --dart-define=API sets the default.
String baseUrl = const String.fromEnvironment('API', defaultValue: 'http://192.168.1.9:8000');

// Single-mall MVP. Mutable so the Advanced/Dev setting can repoint the device;
// loaded from the Meta table at startup, defaults to 1.
int mallId = 1;

// Minutes before the same campaign can notify the same device again.
// Runtime-tweakable via the Advanced panel (persisted in Meta).
int cooldownMinutes = 30;

// Eddystone-UID namespace (10 bytes) = "BLEMALL001". The Pi advertises this + a
// 6-byte instance (= beacon adv_id). The app only reacts to this namespace.
const eddystoneNamespace = '424c454d414c4c303031';
