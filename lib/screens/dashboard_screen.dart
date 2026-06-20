import 'package:flutter/material.dart';
import 'package:flutter_tailwind_colors/flutter_tailwind_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
  double _waterLevel = 60;
  double _ph = 7.2;
  double _temperature = 28;
  double _tds = 350;
  bool _isSimulation = false;
  bool _pumpInlet = false;
  bool _pumpOutlet = false;
  bool _mqttConnected = false;
  final Map<String, _ThresholdSet> _thresholds = {};

  @override
  void initState() {
    super.initState();
    _thresholds.addAll({
      'water_level': _ThresholdSet(
        safe: const [_ThresholdRange(min: 70, max: 100)],
        warning: const [_ThresholdRange(min: 50, max: 70)],
        danger: const [_ThresholdRange(min: 0, max: 50)],
      ),
      'ph': _ThresholdSet(
        safe: const [_ThresholdRange(min: 6.5, max: 8.5)],
        warning: const [
          _ThresholdRange(min: 5.5, max: 6.5),
          _ThresholdRange(min: 8.5, max: 9.0),
        ],
        danger: const [
          _ThresholdRange(min: 0, max: 5.5),
          _ThresholdRange(min: 9.0, max: 14),
        ],
      ),
      'temperature': _ThresholdSet(
        safe: const [_ThresholdRange(min: 26, max: 30)],
        warning: const [
          _ThresholdRange(min: 24, max: 26),
          _ThresholdRange(min: 30, max: 32),
        ],
        danger: const [
          _ThresholdRange(min: 0, max: 24),
          _ThresholdRange(min: 32, max: 50),
        ],
      ),
      'tds': _ThresholdSet(
        safe: const [_ThresholdRange(min: 100, max: 1000)],
        warning: const [_ThresholdRange(min: 1000, max: 1500)],
        danger: const [_ThresholdRange(min: 1500, max: 5000)],
      ),
    });
    _loadThresholds();
  }

  Future<void> _loadThresholds() async {
    final prefs = await SharedPreferences.getInstance();
    for (final entry in _thresholds.entries) {
      final key = entry.key;
      final fallback = entry.value;
      _thresholds[key] = _ThresholdSet(
        safe: _readRanges(prefs, key, 'safe', fallback.safe),
        warning: _readRanges(prefs, key, 'warning', fallback.warning),
        danger: _readRanges(prefs, key, 'danger', fallback.danger),
      );
    }

    if (!mounted) {
      return;
    }
    setState(() {});
  }

  List<_ThresholdRange> _readRanges(
    SharedPreferences prefs,
    String sensorKey,
    String rangeKey,
    List<_ThresholdRange> fallback,
  ) {
    final ranges = <_ThresholdRange>[];
    final firstFallback = fallback.isNotEmpty ? fallback[0] : null;
    final secondFallback = fallback.length > 1 ? fallback[1] : null;
    final first = _readRangeFromPrefs(
      prefs,
      sensorKey,
      rangeKey,
      1,
      firstFallback,
    );
    final second = _readRangeFromPrefs(
      prefs,
      sensorKey,
      rangeKey,
      2,
      secondFallback,
    );

    if (first != null) {
      ranges.add(first);
    }
    if (second != null) {
      ranges.add(second);
    }

    return ranges;
  }

  _ThresholdRange? _readRangeFromPrefs(
    SharedPreferences prefs,
    String sensorKey,
    String rangeKey,
    int index,
    _ThresholdRange? fallback,
  ) {
    final minKey = '${sensorKey}_${rangeKey}_min$index';
    final maxKey = '${sensorKey}_${rangeKey}_max$index';
    final legacyMinKey = '${sensorKey}_${rangeKey}_min';
    final legacyMaxKey = '${sensorKey}_${rangeKey}_max';
    final hasMin =
        prefs.containsKey(minKey) ||
        (index == 1 && prefs.containsKey(legacyMinKey));
    final hasMax =
        prefs.containsKey(maxKey) ||
        (index == 1 && prefs.containsKey(legacyMaxKey));

    if (hasMin || hasMax) {
      final minValue =
          prefs.getString(minKey) ??
          (index == 1 ? prefs.getString(legacyMinKey) : null);
      final maxValue =
          prefs.getString(maxKey) ??
          (index == 1 ? prefs.getString(legacyMaxKey) : null);
      final min = double.tryParse(minValue ?? '');
      final max = double.tryParse(maxValue ?? '');

      if (min == null || max == null) {
        return null;
      }
      return _ThresholdRange(min: min, max: max);
    }

    return fallback;
  }

  _MetricStatus _statusForValue(double value, _ThresholdSet thresholds) {
    if (_inRanges(value, thresholds.safe)) {
      return _MetricStatus(
        label: 'Normal',
        background: TWColors.emerald.shade100,
        text: TWColors.emerald.shade700,
      );
    }
    if (_inRanges(value, thresholds.warning)) {
      return _MetricStatus(
        label: 'Warning',
        background: TWColors.amber.shade100,
        text: TWColors.amber.shade700,
      );
    }
    if (_inRanges(value, thresholds.danger)) {
      return _MetricStatus(
        label: 'Bahaya',
        background: TWColors.red.shade100,
        text: TWColors.red.shade700,
      );
    }

    return _MetricStatus(
      label: 'Unknown',
      background: TWColors.gray.shade200,
      text: TWColors.gray.shade700,
    );
  }

  bool _inRanges(double value, List<_ThresholdRange> ranges) {
    for (final range in ranges) {
      if (_inRange(value, range)) {
        return true;
      }
    }
    return false;
  }

  bool _inRange(double value, _ThresholdRange range) {
    return value >= range.min && value <= range.max;
  }

  Widget _buildModeTab({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    final Color background = selected
        ? TWColors.blue.shade600
        : Colors.transparent;
    final Color textColor = selected ? TWColors.white : TWColors.gray.shade600;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: background,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: textColor,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMqttModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.6),
      builder: (_) => _MqttConnectModal(
        onConnect: () {
          // TODO: implement real MQTT connection
          setState(() => _mqttConnected = true);
          Navigator.pop(context);
        },
        onDisconnect: () {
          setState(() => _mqttConnected = false);
          Navigator.pop(context);
        },
        isConnected: _mqttConnected,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final headerStart = TWColors.blue.shade700;
    final headerEnd = TWColors.blue.shade400;
    final headerText = TWColors.white;
    final headerSubtext = TWColors.blue.shade100;
    final headerIcon = TWColors.blue.shade700;
    final bool showSimulation = _isSimulation;
    final waterStatus = _statusForValue(
      _waterLevel,
      _thresholds['water_level']!,
    );
    final phStatus = _statusForValue(_ph, _thresholds['ph']!);
    final tempStatus = _statusForValue(
      _temperature,
      _thresholds['temperature']!,
    );
    final tdsStatus = _statusForValue(_tds, _thresholds['tds']!);

    return Scaffold(
      backgroundColor: TWColors.blue.shade50,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [headerStart, headerEnd],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 10),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: TWColors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.water_drop_rounded,
                          color: headerIcon,
                          size: 24,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SIMONLE',
                              style: TextStyle(
                                color: headerText,
                                fontWeight: FontWeight.w700,
                                fontSize: 18,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Sistem Monitoring Kolam Lele',
                              style: TextStyle(
                                color: headerSubtext,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // MQTT connect button
                      GestureDetector(
                        onTap: _showMqttModal,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: _mqttConnected
                                ? TWColors.emerald.shade500
                                : TWColors.white.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: TWColors.white.withValues(alpha: 0.4),
                              width: 1,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _mqttConnected
                                    ? Icons.wifi_rounded
                                    : Icons.wifi_off_rounded,
                                size: 14,
                                color: TWColors.white,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                _mqttConnected ? 'Connected' : 'Connect',
                                style: TextStyle(
                                  color: TWColors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Transform.translate(
                    offset: const Offset(0, 10),
                    child: Container(
                      decoration: BoxDecoration(
                        color: TWColors.white,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: TWColors.gray.shade300,
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              'Selamat Datang, Peternak Lele!',
                              style: TextStyle(
                                color: TWColors.gray.shade800,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Pantau kondisi kolam lele Anda secara real-time dan pastikan semuanya berjalan dengan baik.',
                              style: TextStyle(
                                color: TWColors.gray.shade600,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.all(4),
                              decoration: BoxDecoration(
                                color: TWColors.gray.shade100,
                                borderRadius: BorderRadius.circular(999),
                                border: Border.all(
                                  color: TWColors.gray.shade200,
                                ),
                              ),
                              child: Row(
                                children: [
                                  _buildModeTab(
                                    label: 'Realtime',
                                    selected: !showSimulation,
                                    onTap: () {
                                      if (showSimulation) {
                                        setState(() {
                                          _isSimulation = false;
                                        });
                                      }
                                    },
                                  ),
                                  const SizedBox(width: 6),
                                  _buildModeTab(
                                    label: 'Simulasi',
                                    selected: showSimulation,
                                    onTap: () {
                                      if (!showSimulation) {
                                        setState(() {
                                          _isSimulation = true;
                                        });
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: TWColors.blue.shade600,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Status Sensor',
                                  style: TextStyle(
                                    color: TWColors.gray.shade800,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: MetricCard(
                                      title: 'Level Air',
                                      value: _waterLevel.toStringAsFixed(0),
                                      unit: '%',
                                      icon: Icons.water_drop_rounded,
                                      iconBg: TWColors.blue.shade100,
                                      iconColor: TWColors.blue.shade700,
                                      status: waterStatus.label,
                                      statusBg: waterStatus.background,
                                      statusText: waterStatus.text,
                                      sliderValue: showSimulation
                                          ? _waterLevel
                                          : null,
                                      sliderMin: showSimulation ? 0 : null,
                                      sliderMax: showSimulation ? 100 : null,
                                      sliderDivisions: showSimulation
                                          ? 100
                                          : null,
                                      sliderLabel: showSimulation
                                          ? '${_waterLevel.toStringAsFixed(0)}%'
                                          : null,
                                      onSliderChanged: showSimulation
                                          ? (value) {
                                              setState(() {
                                                _waterLevel = value;
                                              });
                                            }
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: MetricCard(
                                      title: 'pH Air',
                                      value: _ph.toStringAsFixed(1),
                                      unit: 'pH',
                                      icon: Icons.science_rounded,
                                      iconBg: TWColors.violet.shade100,
                                      iconColor: TWColors.violet.shade700,
                                      status: phStatus.label,
                                      statusBg: phStatus.background,
                                      statusText: phStatus.text,
                                      sliderValue: showSimulation ? _ph : null,
                                      sliderMin: showSimulation ? 0 : null,
                                      sliderMax: showSimulation ? 14 : null,
                                      sliderDivisions: showSimulation
                                          ? 140
                                          : null,
                                      sliderLabel: showSimulation
                                          ? _ph.toStringAsFixed(1)
                                          : null,
                                      onSliderChanged: showSimulation
                                          ? (value) {
                                              setState(() {
                                                _ph = value;
                                              });
                                            }
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: MetricCard(
                                      title: 'Suhu Air',
                                      value: _temperature.toStringAsFixed(0),
                                      unit: '°C',
                                      icon: Icons.thermostat_rounded,
                                      iconBg: TWColors.orange.shade100,
                                      iconColor: TWColors.orange.shade700,
                                      status: tempStatus.label,
                                      statusBg: tempStatus.background,
                                      statusText: tempStatus.text,
                                      sliderValue: showSimulation
                                          ? _temperature
                                          : null,
                                      sliderMin: showSimulation ? 15 : null,
                                      sliderMax: showSimulation ? 40 : null,
                                      sliderDivisions: showSimulation
                                          ? 50
                                          : null,
                                      sliderLabel: showSimulation
                                          ? _temperature.toStringAsFixed(0)
                                          : null,
                                      onSliderChanged: showSimulation
                                          ? (value) {
                                              setState(() {
                                                _temperature = value;
                                              });
                                            }
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: MetricCard(
                                      title: 'TDS',
                                      value: _tds.toStringAsFixed(0),
                                      unit: 'ppm',
                                      icon: Icons.tune_rounded,
                                      iconBg: TWColors.cyan.shade100,
                                      iconColor: TWColors.cyan.shade700,
                                      status: tdsStatus.label,
                                      statusBg: tdsStatus.background,
                                      statusText: tdsStatus.text,
                                      sliderValue: showSimulation ? _tds : null,
                                      sliderMin: showSimulation ? 0 : null,
                                      sliderMax: showSimulation ? 1300 : null,
                                      sliderDivisions: showSimulation
                                          ? 100
                                          : null,
                                      sliderLabel: showSimulation
                                          ? _tds.toStringAsFixed(0)
                                          : null,
                                      onSliderChanged: showSimulation
                                          ? (value) {
                                              setState(() {
                                                _tds = value;
                                              });
                                            }
                                          : null,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Container(
                                  width: 4,
                                  height: 16,
                                  decoration: BoxDecoration(
                                    color: TWColors.blue.shade600,
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'Kontrol Pompa',
                                  style: TextStyle(
                                    color: TWColors.gray.shade800,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: PumpCard(
                                      title: 'Pompa Inlet',
                                      isOn: _pumpInlet,
                                      icon: Icons.arrow_downward_rounded,
                                      iconBg: TWColors.blue.shade100,
                                      iconColor: TWColors.blue.shade700,
                                      onChanged: (val) {
                                        setState(() {
                                          _pumpInlet = val;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: PumpCard(
                                      title: 'Pompa Outlet',
                                      isOn: _pumpOutlet,
                                      icon: Icons.arrow_upward_rounded,
                                      iconBg: TWColors.orange.shade100,
                                      iconColor: TWColors.orange.shade700,
                                      onChanged: (val) {
                                        setState(() {
                                          _pumpOutlet = val;
                                        });
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── MQTT Connect Modal ──────────────────────────────────────────────────────

class _MqttConnectModal extends StatefulWidget {
  const _MqttConnectModal({
    required this.onConnect,
    required this.onDisconnect,
    required this.isConnected,
  });

  final VoidCallback onConnect;
  final VoidCallback onDisconnect;
  final bool isConnected;

  @override
  State<_MqttConnectModal> createState() => _MqttConnectModalState();
}

class _MqttConnectModalState extends State<_MqttConnectModal> {
  final _hostCtrl = TextEditingController(text: '103.197.188.199');
  final _portCtrl = TextEditingController(text: '1883');
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;
  bool _rememberCredentials = true;

  @override
  void dispose() {
    _hostCtrl.dispose();
    _portCtrl.dispose();
    _userCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: BoxDecoration(
        color: TWColors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: TWColors.gray.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Header
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: TWColors.blue.shade100,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      Icons.link_rounded,
                      color: TWColors.blue.shade700,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Connect Broker',
                        style: TextStyle(
                          color: TWColors.gray.shade900,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Setup your MQTT connection',
                        style: TextStyle(
                          color: TWColors.gray.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Broker Host
              _MqttField(
                label: 'Broker Host',
                controller: _hostCtrl,
                icon: Icons.dns_rounded,
                hint: 'e.g. 192.168.1.1',
              ),
              const SizedBox(height: 12),
              // Port
              _MqttField(
                label: 'Port',
                controller: _portCtrl,
                icon: Icons.settings_ethernet_rounded,
                hint: '1883',
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 20),
              // Auth section label
              Row(
                children: [
                  Container(
                    width: 3,
                    height: 14,
                    decoration: BoxDecoration(
                      color: TWColors.blue.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Authentication (Optional)',
                    style: TextStyle(
                      color: TWColors.gray.shade600,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Username
              _MqttField(
                label: 'Username',
                controller: _userCtrl,
                icon: Icons.person_outline_rounded,
                hint: 'Optional',
              ),
              const SizedBox(height: 12),
              // Password
              _MqttField(
                label: 'Password',
                controller: _passCtrl,
                icon: Icons.lock_outline_rounded,
                hint: 'Optional',
                obscure: _obscurePass,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePass
                        ? Icons.visibility_off_rounded
                        : Icons.visibility_rounded,
                    size: 18,
                    color: TWColors.gray.shade400,
                  ),
                  onPressed: () {
                    setState(() => _obscurePass = !_obscurePass);
                  },
                ),
              ),
              const SizedBox(height: 16),
              // Remember credentials
              GestureDetector(
                onTap: () {
                  setState(() => _rememberCredentials = !_rememberCredentials);
                },
                child: Row(
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 22,
                      height: 22,
                      decoration: BoxDecoration(
                        color: _rememberCredentials
                            ? TWColors.blue.shade600
                            : TWColors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(
                          color: _rememberCredentials
                              ? TWColors.blue.shade600
                              : TWColors.gray.shade300,
                        ),
                      ),
                      child: _rememberCredentials
                          ? const Icon(
                              Icons.check_rounded,
                              size: 14,
                              color: Colors.white,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Remember credentials',
                      style: TextStyle(
                        color: TWColors.gray.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // Connect / Disconnect button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: widget.isConnected
                      ? widget.onDisconnect
                      : widget.onConnect,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.isConnected
                        ? TWColors.red.shade500
                        : TWColors.blue.shade600,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    widget.isConnected ? 'DISCONNECT' : 'CONNECT',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MqttField extends StatelessWidget {
  const _MqttField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
    this.suffixIcon,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 2, bottom: 6),
          child: Text(
            label,
            style: TextStyle(
              color: TWColors.gray.shade500,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          style: TextStyle(
            color: TWColors.gray.shade800,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: TWColors.gray.shade400,
              fontSize: 14,
            ),
            prefixIcon: Icon(
              icon,
              size: 18,
              color: TWColors.blue.shade500,
            ),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: TWColors.gray.shade50,
            isDense: true,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TWColors.gray.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: TWColors.gray.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: TWColors.blue.shade400,
                width: 1.5,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PumpCard extends StatelessWidget {
  const PumpCard({
    super.key,
    required this.title,
    required this.isOn,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.onChanged,
  });

  final String title;
  final bool isOn;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final statusBg = isOn ? TWColors.emerald.shade100 : TWColors.gray.shade100;
    final statusText = isOn ? TWColors.emerald.shade700 : TWColors.gray.shade500;
    final statusLabel = isOn ? 'ON' : 'OFF';
    final activeIconBg = isOn ? iconBg : TWColors.gray.shade100;
    final activeIconColor = isOn ? iconColor : TWColors.gray.shade400;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: TWColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: TWColors.gray.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: TWColors.gray.shade300,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: activeIconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: activeIconColor, size: 16),
              ),
              const Spacer(),
              Transform.scale(
                scale: 0.8,
                child: Switch(
                  value: isOn,
                  onChanged: onChanged,
                  activeThumbColor: iconColor,
                  activeTrackColor: iconColor.withValues(alpha: 0.3),
                  inactiveThumbColor: TWColors.gray.shade400,
                  inactiveTrackColor: TWColors.gray.shade200,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              color: TWColors.gray.shade800,
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              statusLabel,
              style: TextStyle(
                color: statusText,
                fontWeight: FontWeight.w700,
                fontSize: 11,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class MetricCard extends StatelessWidget {
  const MetricCard({
    super.key,
    required this.title,
    required this.value,
    required this.status,
    required this.statusBg,
    required this.statusText,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    this.unit,
    this.sliderValue,
    this.sliderMin,
    this.sliderMax,
    this.sliderDivisions,
    this.sliderLabel,
    this.onSliderChanged,
  });

  final String title;
  final String value;
  final String status;
  final Color statusBg;
  final Color statusText;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String? unit;
  final double? sliderValue;
  final double? sliderMin;
  final double? sliderMax;
  final int? sliderDivisions;
  final String? sliderLabel;
  final ValueChanged<double>? onSliderChanged;

  @override
  Widget build(BuildContext context) {
    const titleBlockHeight = 32.0;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: TWColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: TWColors.gray.shade300,
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: titleBlockHeight,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 16),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: TWColors.gray.shade600,
                      fontWeight: FontWeight.w500,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.center,
            child: Text(
              unit == null ? value : '$value $unit',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: TWColors.gray.shade900,
                fontWeight: FontWeight.w700,
                fontSize: 24,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: statusText,
                fontWeight: FontWeight.w600,
                fontSize: 11,
              ),
            ),
          ),
          if (sliderValue != null &&
              sliderMin != null &&
              sliderMax != null &&
              onSliderChanged != null) ...[
            const SizedBox(height: 8),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
              ),
              child: Slider(
                value: sliderValue!,
                min: sliderMin!,
                max: sliderMax!,
                divisions: sliderDivisions,
                label: sliderLabel,
                activeColor: iconColor,
                inactiveColor: iconBg,
                onChanged: onSliderChanged,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _ThresholdSet {
  const _ThresholdSet({
    required this.safe,
    required this.warning,
    required this.danger,
  });

  final List<_ThresholdRange> safe;
  final List<_ThresholdRange> warning;
  final List<_ThresholdRange> danger;
}

class _ThresholdRange {
  const _ThresholdRange({required this.min, required this.max});

  final double min;
  final double max;
}

class _MetricStatus {
  const _MetricStatus({
    required this.label,
    required this.background,
    required this.text,
  });

  final String label;
  final Color background;
  final Color text;
}
