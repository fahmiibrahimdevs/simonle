import 'package:flutter/material.dart';
import 'package:flutter_tailwind_colors/flutter_tailwind_colors.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final List<_SensorConfig> _sensors = [];

  // Timing controllers
  final TextEditingController _intervalSiklusCtrl = TextEditingController(text: '30');
  final TextEditingController _durasiPompaCtrl = TextEditingController(text: '15');
  final TextEditingController _tambahanWaktuCtrl = TextEditingController(text: '15');

  @override
  void initState() {
    super.initState();
    _sensors.addAll([
      _SensorConfig(
        keyName: 'water_level',
        title: 'Level Air',
        icon: Icons.water_drop_rounded,
        iconBg: TWColors.blue.shade100,
        iconColor: TWColors.blue.shade700,
        safeDefaults: const _RangeDefaults(min1: '70', max1: '100'),
        warningDefaults: const _RangeDefaults(min1: '50', max1: '70'),
        dangerDefaults: const _RangeDefaults(min1: '0', max1: '50'),
      ),
      _SensorConfig(
        keyName: 'ph',
        title: 'pH Air',
        icon: Icons.science_rounded,
        iconBg: TWColors.violet.shade100,
        iconColor: TWColors.violet.shade700,
        safeDefaults: const _RangeDefaults(min1: '6.5', max1: '8.5'),
        warningDefaults: const _RangeDefaults(
          min1: '5.5',
          max1: '6.5',
          min2: '8.5',
          max2: '9.0',
        ),
        dangerDefaults: const _RangeDefaults(
          min1: '0',
          max1: '5.5',
          min2: '9.0',
          max2: '14',
        ),
      ),
      _SensorConfig(
        keyName: 'temperature',
        title: 'Suhu Air',
        icon: Icons.thermostat_rounded,
        iconBg: TWColors.orange.shade100,
        iconColor: TWColors.orange.shade700,
        safeDefaults: const _RangeDefaults(min1: '26', max1: '30'),
        warningDefaults: const _RangeDefaults(
          min1: '24',
          max1: '26',
          min2: '30',
          max2: '32',
        ),
        dangerDefaults: const _RangeDefaults(
          min1: '0',
          max1: '24',
          min2: '32',
          max2: '50',
        ),
      ),
      _SensorConfig(
        keyName: 'tds',
        title: 'TDS',
        icon: Icons.tune_rounded,
        iconBg: TWColors.cyan.shade100,
        iconColor: TWColors.cyan.shade700,
        safeDefaults: const _RangeDefaults(min1: '100', max1: '1000'),
        warningDefaults: const _RangeDefaults(min1: '1000', max1: '1500'),
        dangerDefaults: const _RangeDefaults(min1: '1500', max1: '5000'),
      ),
    ]);
    _applyDefaultRanges();
    _loadSavedRanges();
    _loadTimingSettings();
  }

  @override
  void dispose() {
    for (final sensor in _sensors) {
      sensor.dispose();
    }
    _intervalSiklusCtrl.dispose();
    _durasiPompaCtrl.dispose();
    _tambahanWaktuCtrl.dispose();
    super.dispose();
  }

  void _applyDefaultRanges() {
    for (final sensor in _sensors) {
      _applyRangeDefaults(sensor.safeRange, sensor.safeDefaults);
      _applyRangeDefaults(sensor.warningRange, sensor.warningDefaults);
      _applyRangeDefaults(sensor.dangerRange, sensor.dangerDefaults);
    }
  }

  void _applyRangeDefaults(_RangeControllers range, _RangeDefaults defaults) {
    range.min1.text = defaults.min1;
    range.max1.text = defaults.max1;
    range.min2.text = defaults.min2 ?? '';
    range.max2.text = defaults.max2 ?? '';
  }

  void _collapseOtherTiles(_SensorConfig opened) {
    for (final sensor in _sensors) {
      if (sensor != opened) {
        sensor.controller.collapse();
      }
    }
  }

  Future<void> _loadSavedRanges() async {
    final prefs = await SharedPreferences.getInstance();
    for (final sensor in _sensors) {
      _loadRangeValues(prefs, sensor.keyName, 'safe', sensor.safeRange);
      _loadRangeValues(prefs, sensor.keyName, 'warning', sensor.warningRange);
      _loadRangeValues(prefs, sensor.keyName, 'danger', sensor.dangerRange);
    }
  }

  Future<void> _loadTimingSettings() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('timing_interval_siklus')) {
      _intervalSiklusCtrl.text = prefs.getString('timing_interval_siklus') ?? '30';
    }
    if (prefs.containsKey('timing_durasi_pompa')) {
      _durasiPompaCtrl.text = prefs.getString('timing_durasi_pompa') ?? '15';
    }
    if (prefs.containsKey('timing_tambahan_waktu')) {
      _tambahanWaktuCtrl.text = prefs.getString('timing_tambahan_waktu') ?? '15';
    }
  }

  Future<void> _saveTimingSettings() async {
    final interval = int.tryParse(_intervalSiklusCtrl.text.trim());
    final durasi = int.tryParse(_durasiPompaCtrl.text.trim());
    final tambahan = int.tryParse(_tambahanWaktuCtrl.text.trim());

    if (interval == null || durasi == null || tambahan == null || interval <= 0) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Nilai harus berupa angka dan lebih dari 0.'),
          backgroundColor: TWColors.red.shade600,
        ),
      );
      return;
    }

    if (durasi >= interval) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Durasi pompa ($durasi mnt) harus kurang dari interval siklus ($interval mnt).'
          ),
          backgroundColor: TWColors.red.shade600,
        ),
      );
      return;
    }

    if (tambahan >= interval) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Tambahan waktu ($tambahan mnt) harus kurang dari interval siklus ($interval mnt).'
          ),
          backgroundColor: TWColors.red.shade600,
        ),
      );
      return;
    }

    final prefs = await SharedPreferences.getInstance();
    await Future.wait([
      prefs.setString('timing_interval_siklus', _intervalSiklusCtrl.text.trim()),
      prefs.setString('timing_durasi_pompa', _durasiPompaCtrl.text.trim()),
      prefs.setString('timing_tambahan_waktu', _tambahanWaktuCtrl.text.trim()),
    ]);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Pengaturan jadwal & durasi tersimpan.'),
        backgroundColor: TWColors.emerald.shade600,
      ),
    );
  }

  void _loadRangeValues(
    SharedPreferences prefs,
    String sensorKey,
    String rangeKey,
    _RangeControllers range,
  ) {
    final min1Key = '${sensorKey}_${rangeKey}_min1';
    final max1Key = '${sensorKey}_${rangeKey}_max1';
    final min2Key = '${sensorKey}_${rangeKey}_min2';
    final max2Key = '${sensorKey}_${rangeKey}_max2';
    final legacyMinKey = '${sensorKey}_${rangeKey}_min';
    final legacyMaxKey = '${sensorKey}_${rangeKey}_max';

    if (prefs.containsKey(min1Key)) {
      range.min1.text = prefs.getString(min1Key) ?? '';
    } else if (prefs.containsKey(legacyMinKey)) {
      range.min1.text = prefs.getString(legacyMinKey) ?? '';
    }

    if (prefs.containsKey(max1Key)) {
      range.max1.text = prefs.getString(max1Key) ?? '';
    } else if (prefs.containsKey(legacyMaxKey)) {
      range.max1.text = prefs.getString(legacyMaxKey) ?? '';
    }

    if (prefs.containsKey(min2Key)) {
      range.min2.text = prefs.getString(min2Key) ?? '';
    }

    if (prefs.containsKey(max2Key)) {
      range.max2.text = prefs.getString(max2Key) ?? '';
    }
  }

  Future<void> _saveSensorRanges(_SensorConfig sensor) async {
    final prefs = await SharedPreferences.getInstance();
    final futures = <Future<bool>>[
      _saveRangeValues(prefs, sensor.keyName, 'safe', sensor.safeRange),
      _saveRangeValues(prefs, sensor.keyName, 'warning', sensor.warningRange),
      _saveRangeValues(prefs, sensor.keyName, 'danger', sensor.dangerRange),
    ];

    await Future.wait(futures);
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Ambang batas ${sensor.title} tersimpan.'),
        backgroundColor: TWColors.emerald.shade600,
      ),
    );
  }

  Future<bool> _saveRangeValues(
    SharedPreferences prefs,
    String sensorKey,
    String rangeKey,
    _RangeControllers range,
  ) {
    final min1Value = range.min1.text.trim();
    final max1Value = range.max1.text.trim();
    final min2Value = range.min2.text.trim();
    final max2Value = range.max2.text.trim();

    return Future.wait([
      prefs.setString('${sensorKey}_${rangeKey}_min1', min1Value),
      prefs.setString('${sensorKey}_${rangeKey}_max1', max1Value),
      prefs.setString('${sensorKey}_${rangeKey}_min2', min2Value),
      prefs.setString('${sensorKey}_${rangeKey}_max2', max2Value),
      prefs.setString('${sensorKey}_${rangeKey}_min', min1Value),
      prefs.setString('${sensorKey}_${rangeKey}_max', max1Value),
    ]).then((_) => true);
  }

  @override
  Widget build(BuildContext context) {
    final headerStart = TWColors.blue.shade700;
    final headerEnd = TWColors.blue.shade400;
    final headerText = TWColors.white;
    final headerSubtext = TWColors.blue.shade100;
    final headerIcon = TWColors.blue.shade700;

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
                      Column(
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
                            const SizedBox(height: 8),
                            Text(
                              'Konfigurasi Ambang Batas',
                              style: TextStyle(
                                color: TWColors.gray.shade800,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Atur ambang batas untuk berbagai parameter kolam lele Anda.',
                              style: TextStyle(
                                color: TWColors.gray.shade600,
                                fontWeight: FontWeight.w400,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 16),
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
                                  'Parameter Kualitas Air',
                                  style: TextStyle(
                                    color: TWColors.gray.shade800,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            for (final sensor in _sensors) ...[
                              ConfigCard(
                                title: sensor.title,
                                icon: sensor.icon,
                                iconBg: sensor.iconBg,
                                iconColor: sensor.iconColor,
                                safeRange: sensor.safeRange,
                                warningRange: sensor.warningRange,
                                dangerRange: sensor.dangerRange,
                                onSave: () => _saveSensorRanges(sensor),
                                controller: sensor.controller,
                                onExpanded: () => _collapseOtherTiles(sensor),
                              ),
                              const SizedBox(height: 16),
                            ],
                            const SizedBox(height: 8),
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
                                  'Jadwal & Durasi Pompa',
                                  style: TextStyle(
                                    color: TWColors.gray.shade800,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Atur interval siklus dan durasi pompa bekerja secara otomatis.',
                              style: TextStyle(
                                color: TWColors.gray.shade500,
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 12),
                            TimingConfigCard(
                              intervalSiklusCtrl: _intervalSiklusCtrl,
                              durasiPompaCtrl: _durasiPompaCtrl,
                              tambahanWaktuCtrl: _tambahanWaktuCtrl,
                              onSave: _saveTimingSettings,
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

class TimingConfigCard extends StatelessWidget {
  const TimingConfigCard({
    super.key,
    required this.intervalSiklusCtrl,
    required this.durasiPompaCtrl,
    required this.tambahanWaktuCtrl,
    required this.onSave,
  });

  final TextEditingController intervalSiklusCtrl;
  final TextEditingController durasiPompaCtrl;
  final TextEditingController tambahanWaktuCtrl;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
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
          _TimingRow(
            icon: Icons.schedule_rounded,
            iconBg: TWColors.blue.shade100,
            iconColor: TWColors.blue.shade700,
            label: 'Interval Siklus',
            sublabel: 'Sistem mulai 1 siklus setiap ...',
            unit: 'menit',
            controller: intervalSiklusCtrl,
          ),
          const SizedBox(height: 4),
          Divider(color: TWColors.gray.shade100, height: 24),
          _TimingRow(
            icon: Icons.water_drop_rounded,
            iconBg: TWColors.cyan.shade100,
            iconColor: TWColors.cyan.shade700,
            label: 'Durasi Pompa',
            sublabel: 'Pompa ON di awal siklus selama ...',
            unit: 'menit',
            controller: durasiPompaCtrl,
          ),
          const SizedBox(height: 4),
          Divider(color: TWColors.gray.shade100, height: 24),
          _TimingRow(
            icon: Icons.more_time_rounded,
            iconBg: TWColors.amber.shade100,
            iconColor: TWColors.amber.shade700,
            label: 'Tambahan Waktu',
            sublabel: 'Ditambahkan jika kondisi belum normal',
            unit: 'menit',
            controller: tambahanWaktuCtrl,
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: SizedBox(
              height: 36,
              child: ElevatedButton.icon(
                onPressed: onSave,
                icon: const Icon(Icons.save_rounded, size: 16),
                label: const Text('Simpan'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: TWColors.blue.shade600,
                  foregroundColor: TWColors.white,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TimingRow extends StatelessWidget {
  const _TimingRow({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.label,
    required this.sublabel,
    required this.unit,
    required this.controller,
  });

  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final String label;
  final String sublabel;
  final String unit;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: iconBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 18),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: TWColors.gray.shade800,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                sublabel,
                style: TextStyle(
                  color: TWColors.gray.shade400,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 60,
          child: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: TWColors.gray.shade800,
              fontWeight: FontWeight.w700,
              fontSize: 14,
            ),
            decoration: InputDecoration(
              isDense: true,
              filled: true,
              fillColor: TWColors.gray.shade50,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 10,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: TWColors.gray.shade200),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: TWColors.gray.shade200),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide(color: TWColors.blue.shade400),
              ),
            ),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          unit,
          style: TextStyle(
            color: TWColors.gray.shade500,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _RangeControllers {
  _RangeControllers()
    : min1 = TextEditingController(),
      max1 = TextEditingController(),
      min2 = TextEditingController(),
      max2 = TextEditingController();

  final TextEditingController min1;
  final TextEditingController max1;
  final TextEditingController min2;
  final TextEditingController max2;

  void dispose() {
    min1.dispose();
    max1.dispose();
    min2.dispose();
    max2.dispose();
  }
}

class _RangeDefaults {
  const _RangeDefaults({
    required this.min1,
    required this.max1,
    this.min2,
    this.max2,
  });

  final String min1;
  final String max1;
  final String? min2;
  final String? max2;
}

class _SensorConfig {
  _SensorConfig({
    required this.keyName,
    required this.title,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.safeDefaults,
    required this.warningDefaults,
    required this.dangerDefaults,
  }) : safeRange = _RangeControllers(),
       warningRange = _RangeControllers(),
       dangerRange = _RangeControllers(),
       controller = ExpansionTileController();

  final String keyName;
  final String title;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final _RangeDefaults safeDefaults;
  final _RangeDefaults warningDefaults;
  final _RangeDefaults dangerDefaults;
  final _RangeControllers safeRange;
  final _RangeControllers warningRange;
  final _RangeControllers dangerRange;
  final ExpansionTileController controller;

  void dispose() {
    safeRange.dispose();
    warningRange.dispose();
    dangerRange.dispose();
  }
}

class ConfigCard extends StatelessWidget {
  const ConfigCard({
    super.key,
    required this.title,
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.safeRange,
    required this.warningRange,
    required this.dangerRange,
    required this.onSave,
    required this.controller,
    required this.onExpanded,
  });

  final String title;
  final IconData icon;
  final Color iconBg;
  final Color iconColor;
  final _RangeControllers safeRange;
  final _RangeControllers warningRange;
  final _RangeControllers dangerRange;
  final VoidCallback onSave;
  final ExpansionTileController controller;
  final VoidCallback onExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            controller: controller,
            tilePadding: const EdgeInsets.fromLTRB(16, 12, 12, 12),
            childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            backgroundColor: TWColors.white,
            collapsedBackgroundColor: TWColors.white,
            iconColor: TWColors.blue.shade600,
            collapsedIconColor: TWColors.gray.shade500,
            onExpansionChanged: (expanded) {
              if (expanded) {
                onExpanded();
              }
            },
            title: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(icon, color: iconColor, size: 18),
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: TextStyle(
                    color: TWColors.gray.shade800,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            children: [
              _RangeSection(
                label: 'Aman',
                labelBg: Color(0xFFD1FAE5),
                labelText: Color(0xFF047857),
                min1Controller: safeRange.min1,
                max1Controller: safeRange.max1,
                min2Controller: safeRange.min2,
                max2Controller: safeRange.max2,
              ),
              const SizedBox(height: 12),
              _RangeSection(
                label: 'Warning',
                labelBg: Color(0xFFFEF3C7),
                labelText: Color(0xFFB45309),
                min1Controller: warningRange.min1,
                max1Controller: warningRange.max1,
                min2Controller: warningRange.min2,
                max2Controller: warningRange.max2,
              ),
              const SizedBox(height: 12),
              _RangeSection(
                label: 'Bahaya',
                labelBg: Color(0xFFFEE2E2),
                labelText: Color(0xFFB91C1C),
                min1Controller: dangerRange.min1,
                max1Controller: dangerRange.max1,
                min2Controller: dangerRange.min2,
                max2Controller: dangerRange.max2,
              ),
              const SizedBox(height: 16),
              Align(
                alignment: Alignment.centerRight,
                child: SizedBox(
                  height: 36,
                  child: ElevatedButton.icon(
                    onPressed: onSave,
                    icon: const Icon(Icons.save_rounded, size: 16),
                    label: const Text('Simpan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: TWColors.blue.shade600,
                      foregroundColor: TWColors.white,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14),
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

class _RangeSection extends StatelessWidget {
  const _RangeSection({
    required this.label,
    required this.labelBg,
    required this.labelText,
    required this.min1Controller,
    required this.max1Controller,
    required this.min2Controller,
    required this.max2Controller,
  });

  final String label;
  final Color labelBg;
  final Color labelText;
  final TextEditingController min1Controller;
  final TextEditingController max1Controller;
  final TextEditingController min2Controller;
  final TextEditingController max2Controller;

  @override
  Widget build(BuildContext context) {
    final rangeListenable = Listenable.merge([
      min1Controller,
      max1Controller,
      min2Controller,
      max2Controller,
    ]);

    String? buildSummary() {
      final min1 = min1Controller.text.trim();
      final max1 = max1Controller.text.trim();
      final min2 = min2Controller.text.trim();
      final max2 = max2Controller.text.trim();

      final first = min1.isNotEmpty && max1.isNotEmpty ? '$min1 - $max1' : '';
      final second = min2.isNotEmpty && max2.isNotEmpty ? '$min2 - $max2' : '';

      if (first.isEmpty && second.isEmpty) {
        return null;
      }
      if (first.isEmpty) {
        return 'Kamu Set: $second';
      }
      if (second.isEmpty) {
        return 'Kamu Set: $first';
      }

      return 'Kamu Set: $first atau $second';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: labelText,
            fontWeight: FontWeight.w600,
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _RangeInputField(hint: 'Min', controller: min1Controller),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RangeInputField(hint: 'Max', controller: max1Controller),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'atau',
          style: TextStyle(color: TWColors.gray.shade500, fontSize: 11),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _RangeInputField(hint: 'Min', controller: min2Controller),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _RangeInputField(hint: 'Max', controller: max2Controller),
            ),
          ],
        ),
        AnimatedBuilder(
          animation: rangeListenable,
          builder: (context, _) {
            final summary = buildSummary();
            if (summary == null) {
              return const SizedBox.shrink();
            }
            return Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                summary,
                style: TextStyle(color: TWColors.gray.shade500, fontSize: 11),
              ),
            );
          },
        ),
      ],
    );
  }
}

class _RangeInputField extends StatelessWidget {
  const _RangeInputField({required this.hint, required this.controller});

  final String hint;
  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: TextStyle(
        color: TWColors.gray.shade800,
        fontWeight: FontWeight.w500,
        fontSize: 12,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: TWColors.gray.shade400, fontSize: 12),
        isDense: true,
        filled: true,
        fillColor: TWColors.gray.shade50,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 10,
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
          borderSide: BorderSide(color: TWColors.blue.shade400),
        ),
      ),
    );
  }
}
