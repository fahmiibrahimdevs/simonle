import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

// ─── Status Enum ─────────────────────────────────────────────────────────────

enum MqttConnectStatus { disconnected, connecting, connected, error }

// ─── MqttService ─────────────────────────────────────────────────────────────

class MqttService extends ChangeNotifier {
  MqttServerClient? _client;
  MqttConnectStatus _status = MqttConnectStatus.disconnected;
  String? _errorMessage;
  bool _intentionalDisconnect = false;

  // ── Getters ──────────────────────────────────────────────────────────────

  MqttConnectStatus get status => _status;
  String? get errorMessage => _errorMessage;
  bool get isConnected => _status == MqttConnectStatus.connected;
  bool get isConnecting => _status == MqttConnectStatus.connecting;
  bool get hasError => _status == MqttConnectStatus.error;

  // ── Saved credentials (loaded from SharedPreferences) ────────────────────

  String savedHost = '103.197.188.199';
  int savedPort = 1883;
  String savedUsername = '';
  String savedPassword = '';
  bool savedRemember = true;

  /// Load previously saved credentials from SharedPreferences.
  Future<void> loadSavedCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    savedHost = prefs.getString('mqtt_host') ?? '103.197.188.199';
    savedPort = prefs.getInt('mqtt_port') ?? 1883;
    savedUsername = prefs.getString('mqtt_username') ?? '';
    savedPassword = prefs.getString('mqtt_password') ?? '';
    savedRemember = prefs.getBool('mqtt_remember') ?? true;
    notifyListeners();
  }

  /// Persist credentials to SharedPreferences.
  Future<void> saveCredentials({
    required String host,
    required int port,
    required String username,
    required String password,
    required bool remember,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    if (remember) {
      await prefs.setString('mqtt_host', host);
      await prefs.setInt('mqtt_port', port);
      await prefs.setString('mqtt_username', username);
      await prefs.setString('mqtt_password', password);
      await prefs.setBool('mqtt_remember', true);
    } else {
      // Clear saved credentials if remember is unchecked
      await prefs.remove('mqtt_host');
      await prefs.remove('mqtt_port');
      await prefs.remove('mqtt_username');
      await prefs.remove('mqtt_password');
      await prefs.setBool('mqtt_remember', false);
    }
  }

  // ── Connection ────────────────────────────────────────────────────────────

  /// Connect to the MQTT broker.
  /// Throws nothing — errors are reflected in [status] and [errorMessage].
  Future<void> connect({
    required String host,
    required int port,
    String? username,
    String? password,
  }) async {
    if (_status == MqttConnectStatus.connecting) return;

    // Clean up any existing connection
    if (_client != null) {
      _intentionalDisconnect = true;
      _client!.disconnect();
      _client = null;
    }

    _intentionalDisconnect = false;
    _status = MqttConnectStatus.connecting;
    _errorMessage = null;
    notifyListeners();

    // Generate a short unique client ID
    final uid = const Uuid().v4().replaceAll('-', '').substring(0, 8);
    final clientId = 'simonle_$uid';

    _client = MqttServerClient.withPort(host, clientId, port);
    _client!
      ..logging(on: kDebugMode)
      ..keepAlivePeriod = 30
      ..connectTimeoutPeriod = 10000
      ..onConnected = _onConnected
      ..onDisconnected = _onDisconnected;

    // Build connection message
    final connMsg = MqttConnectMessage()
        .withClientIdentifier(clientId)
        .startClean()
        .withWillQos(MqttQos.atLeastOnce);

    if (username != null && username.isNotEmpty) {
      connMsg.authenticateAs(username, password ?? '');
    }

    _client!.connectionMessage = connMsg;

    try {
      await _client!.connect();
    } on Exception catch (e) {
      _status = MqttConnectStatus.error;
      _errorMessage = _friendlyError(e.toString());
      _client?.disconnect();
      _client = null;
      notifyListeners();
      return;
    }

    final state = _client?.connectionStatus?.state;
    if (state == MqttConnectionState.connected) {
      _status = MqttConnectStatus.connected;
      _errorMessage = null;
    } else {
      final returnCode = _client?.connectionStatus?.returnCode;
      _status = MqttConnectStatus.error;
      _errorMessage = _friendlyReturnCode(returnCode);
      _client?.disconnect();
      _client = null;
    }
    notifyListeners();
  }

  /// Disconnect from broker.
  void disconnect() {
    _intentionalDisconnect = true;
    _client?.disconnect();
    _client = null;
    _status = MqttConnectStatus.disconnected;
    _errorMessage = null;
    notifyListeners();
  }

  // ── Internal callbacks ────────────────────────────────────────────────────

  void _onConnected() {
    _status = MqttConnectStatus.connected;
    _errorMessage = null;
    notifyListeners();
  }

  void _onDisconnected() {
    if (_intentionalDisconnect) return;
    // Unexpected disconnect
    _client = null;
    _status = MqttConnectStatus.error;
    _errorMessage = 'Koneksi terputus dari broker.';
    notifyListeners();
  }

  // ── Error messages ────────────────────────────────────────────────────────

  String _friendlyError(String raw) {
    if (raw.contains('SocketException') || raw.contains('Connection refused')) {
      return 'Tidak dapat terhubung. Periksa host & port.';
    }
    if (raw.contains('TimeoutException') || raw.contains('timed out')) {
      return 'Koneksi timeout. Periksa jaringan Anda.';
    }
    if (raw.contains('HandshakeException')) {
      return 'Gagal handshake TLS/SSL dengan broker.';
    }
    return 'Error: $raw';
  }

  String _friendlyReturnCode(dynamic code) {
    final s = code?.toString() ?? '';
    if (s.contains('badUsernameOrPassword')) {
      return 'Username atau password salah.';
    }
    if (s.contains('notAuthorized')) {
      return 'Tidak diizinkan terhubung ke broker ini.';
    }
    if (s.contains('identifierRejected')) {
      return 'Client ID ditolak oleh broker.';
    }
    if (s.contains('serverUnavailable')) {
      return 'Broker tidak tersedia saat ini.';
    }
    return 'Gagal terhubung (${code ?? "unknown"}).';
  }

  // ── Dispose ───────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _intentionalDisconnect = true;
    _client?.disconnect();
    super.dispose();
  }
}
