import 'package:flutter/material.dart';
import 'package:flutter_tailwind_colors/flutter_tailwind_colors.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  DateTime _fromDate = DateTime.now().subtract(const Duration(days: 1));
  DateTime _toDate = DateTime.now();

  // Dummy data — nanti diganti dengan data dari backend/DB
  late final List<_CycleData> _cycles;

  @override
  void initState() {
    super.initState();
    initializeDateFormatting('id', null);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    _cycles = [
      _CycleData(
        cycleNumber: 1,
        startTime: today.add(const Duration(hours: 8)),
        endTime: today.add(const Duration(hours: 8, minutes: 25)),
        isRunning: false,
        events: [
          _CycleEvent.pumpOn(today.add(const Duration(hours: 8))),
          _CycleEvent.sensorRead(
            time: today.add(const Duration(hours: 8, minutes: 15)),
            overallStatus: 'Belum Normal',
            readings: [
              _SensorReading(label: 'Suhu', value: '24.5', unit: '°C', status: 'Warning'),
              _SensorReading(label: 'pH', value: '6.1', unit: 'pH', status: 'Warning'),
              _SensorReading(label: 'TDS', value: '290', unit: 'ppm', status: 'Normal'),
            ],
          ),
          _CycleEvent.sensorRead(
            time: today.add(const Duration(hours: 8, minutes: 20)),
            overallStatus: 'Belum Normal',
            readings: [
              _SensorReading(label: 'Suhu', value: '25.8', unit: '°C', status: 'Warning'),
              _SensorReading(label: 'pH', value: '6.4', unit: 'pH', status: 'Warning'),
              _SensorReading(label: 'TDS', value: '305', unit: 'ppm', status: 'Normal'),
            ],
          ),
          _CycleEvent.sensorRead(
            time: today.add(const Duration(hours: 8, minutes: 25)),
            overallStatus: 'Normal',
            readings: [
              _SensorReading(label: 'Suhu', value: '27.2', unit: '°C', status: 'Normal'),
              _SensorReading(label: 'pH', value: '6.8', unit: 'pH', status: 'Normal'),
              _SensorReading(label: 'TDS', value: '320', unit: 'ppm', status: 'Normal'),
            ],
          ),
        ],
      ),
      _CycleData(
        cycleNumber: 2,
        startTime: today.add(const Duration(hours: 8, minutes: 30)),
        endTime: null,
        isRunning: true,
        events: [
          _CycleEvent.pumpOn(today.add(const Duration(hours: 8, minutes: 30))),
          _CycleEvent.sensorRead(
            time: today.add(const Duration(hours: 8, minutes: 45)),
            overallStatus: 'Belum Normal',
            readings: [
              _SensorReading(label: 'Suhu', value: '26.1', unit: '°C', status: 'Normal'),
              _SensorReading(label: 'pH', value: '5.9', unit: 'pH', status: 'Bahaya'),
              _SensorReading(label: 'TDS', value: '280', unit: 'ppm', status: 'Normal'),
            ],
          ),
        ],
      ),
    ];
  }

  String _formatDate(DateTime d) => DateFormat('dd MMM yyyy', 'id').format(d);
  String _formatTime(DateTime d) => DateFormat('HH:mm').format(d);

  Future<void> _pickDate(bool isFrom) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: isFrom ? _fromDate : _toDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(
              primary: TWColors.blue.shade600,
              onPrimary: TWColors.white,
              surface: TWColors.white,
              onSurface: TWColors.gray.shade800,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked == null) return;
    setState(() {
      if (isFrom) {
        _fromDate = picked;
        if (_fromDate.isAfter(_toDate)) _toDate = _fromDate;
      } else {
        _toDate = picked;
        if (_toDate.isBefore(_fromDate)) _fromDate = _toDate;
      }
    });
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
                // Header
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
                // Content
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
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(height: 0),
                                Text(
                                  'Riwayat Siklus Pompa',
                                  style: TextStyle(
                                    color: TWColors.gray.shade800,
                                    fontWeight: FontWeight.w700,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Lihat rekaman aktivitas pompa dan kondisi sensor.',
                                  style: TextStyle(
                                    color: TWColors.gray.shade500,
                                    fontWeight: FontWeight.w400,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                // Date range filter
                                Row(
                                  children: [
                                    Expanded(
                                      child: _DatePickerButton(
                                        label: 'Dari',
                                        date: _formatDate(_fromDate),
                                        onTap: () => _pickDate(true),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 10),
                                      child: Icon(
                                        Icons.arrow_forward_rounded,
                                        size: 16,
                                        color: TWColors.gray.shade400,
                                      ),
                                    ),
                                    Expanded(
                                      child: _DatePickerButton(
                                        label: 'Sampai',
                                        date: _formatDate(_toDate),
                                        onTap: () => _pickDate(false),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Divider(
                                  color: TWColors.gray.shade100,
                                  height: 1,
                                ),
                                const SizedBox(height: 4),
                              ],
                            ),
                          ),
                          // Cycle list
                          Expanded(
                            child: ListView.separated(
                              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
                              itemCount: _cycles.length,
                              separatorBuilder: (_, _) => const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return _CycleCard(
                                  cycle: _cycles[index],
                                  formatTime: _formatTime,
                                );
                              },
                            ),
                          ),
                        ],
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

// ─── Date Picker Button ─────────────────────────────────────────────────────

class _DatePickerButton extends StatelessWidget {
  const _DatePickerButton({
    required this.label,
    required this.date,
    required this.onTap,
  });

  final String label;
  final String date;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: TWColors.gray.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: TWColors.gray.shade200),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_rounded,
              size: 14,
              color: TWColors.blue.shade600,
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    color: TWColors.gray.shade400,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  date,
                  style: TextStyle(
                    color: TWColors.gray.shade800,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
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

// ─── Cycle Card ─────────────────────────────────────────────────────────────

class _CycleCard extends StatefulWidget {
  const _CycleCard({required this.cycle, required this.formatTime});

  final _CycleData cycle;
  final String Function(DateTime) formatTime;

  @override
  State<_CycleCard> createState() => _CycleCardState();
}

class _CycleCardState extends State<_CycleCard>
    with SingleTickerProviderStateMixin {
  bool _expanded = false;

  late final AnimationController _controller;
  late final Animation<double> _iconTurn;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 220),
      vsync: this,
    );
    _iconTurn = Tween<double>(begin: 0, end: 0.5).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggle() {
    setState(() => _expanded = !_expanded);
    if (_expanded) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  String _timeRange() {
    final start = widget.formatTime(widget.cycle.startTime);
    if (widget.cycle.isRunning) return '$start – ...';
    final end = widget.cycle.endTime != null
        ? widget.formatTime(widget.cycle.endTime!)
        : '...';
    return '$start – $end';
  }

  @override
  Widget build(BuildContext context) {
    final cycle = widget.cycle;
    return Container(
      decoration: BoxDecoration(
        color: TWColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: TWColors.gray.shade200),
        boxShadow: [
          BoxShadow(
            color: TWColors.gray.shade300,
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Column(
          children: [
            // Card header — tap to expand
            InkWell(
              onTap: _toggle,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
                child: Row(
                  children: [
                    // Cycle number badge
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: TWColors.blue.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: Text(
                          '${cycle.cycleNumber}',
                          style: TextStyle(
                            color: TWColors.blue.shade700,
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Siklus ${cycle.cycleNumber}',
                                style: TextStyle(
                                  color: TWColors.gray.shade800,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 13,
                                ),
                              ),
                              if (cycle.isRunning) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: TWColors.amber.shade100,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    'Sedang Berjalan',
                                    style: TextStyle(
                                      color: TWColors.amber.shade700,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: TWColors.gray.shade400,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _timeRange(),
                                style: TextStyle(
                                  color: TWColors.gray.shade500,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    RotationTransition(
                      turns: _iconTurn,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: TWColors.gray.shade500,
                        size: 20,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            // Expandable content
            AnimatedCrossFade(
              duration: const Duration(milliseconds: 220),
              crossFadeState: _expanded
                  ? CrossFadeState.showSecond
                  : CrossFadeState.showFirst,
              firstChild: const SizedBox.shrink(),
              secondChild: Column(
                children: [
                  Divider(
                    height: 1,
                    color: TWColors.gray.shade100,
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
                    child: Column(
                      children: [
                        for (int i = 0; i < cycle.events.length; i++) ...[
                          _EventRow(
                            event: cycle.events[i],
                            formatTime: widget.formatTime,
                            isLast: i == cycle.events.length - 1,
                            isRunning: cycle.isRunning,
                          ),
                          if (i < cycle.events.length - 1)
                            const SizedBox(height: 0),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Event Row ──────────────────────────────────────────────────────────────

class _EventRow extends StatelessWidget {
  const _EventRow({
    required this.event,
    required this.formatTime,
    required this.isLast,
    required this.isRunning,
  });

  final _CycleEvent event;
  final String Function(DateTime) formatTime;
  final bool isLast;
  final bool isRunning;

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Timeline column
          SizedBox(
            width: 44,
            child: Column(
              children: [
                Text(
                  formatTime(event.time),
                  style: TextStyle(
                    color: TWColors.gray.shade500,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Expanded(
                  child: Center(
                    child: Container(
                      width: 1.5,
                      color: isLast && isRunning
                          ? TWColors.amber.shade300
                          : TWColors.gray.shade200,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: event.type == _EventType.pumpOn
                  ? _PumpOnRow()
                  : _SensorReadRow(
                      event: event,
                      isLast: isLast,
                      isRunning: isRunning,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PumpOnRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: TWColors.blue.shade100,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.power_settings_new_rounded,
                size: 12,
                color: TWColors.blue.shade700,
              ),
              const SizedBox(width: 4),
              Text(
                'Pompa ON',
                style: TextStyle(
                  color: TWColors.blue.shade700,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SensorReadRow extends StatelessWidget {
  const _SensorReadRow({
    required this.event,
    required this.isLast,
    required this.isRunning,
  });

  final _CycleEvent event;
  final bool isLast;
  final bool isRunning;

  Color _statusBg(String status) {
    switch (status) {
      case 'Normal':
        return const Color(0xFFD1FAE5);
      case 'Warning':
        return const Color(0xFFFEF3C7);
      case 'Bahaya':
        return const Color(0xFFFEE2E2);
      default:
        return const Color(0xFFF3F4F6);
    }
  }

  Color _statusText(String status) {
    switch (status) {
      case 'Normal':
        return const Color(0xFF047857);
      case 'Warning':
        return const Color(0xFFB45309);
      case 'Bahaya':
        return const Color(0xFFB91C1C);
      default:
        return const Color(0xFF6B7280);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNormal = event.overallStatus == 'Normal';
    final overallBg = isNormal
        ? TWColors.emerald.shade100
        : (isLast && isRunning ? TWColors.amber.shade100 : TWColors.orange.shade100);
    final overallText = isNormal
        ? TWColors.emerald.shade700
        : (isLast && isRunning ? TWColors.amber.shade700 : TWColors.orange.shade700);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Overall status badge
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: overallBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                event.overallStatus ?? '',
                style: TextStyle(
                  color: overallText,
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                ),
              ),
            ),
            if (isLast && isRunning) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: TWColors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: TWColors.amber.shade200),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.more_horiz_rounded,
                      size: 11,
                      color: TWColors.amber.shade600,
                    ),
                    const SizedBox(width: 3),
                    Text(
                      'Masih Running',
                      style: TextStyle(
                        color: TWColors.amber.shade700,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        // Sensor readings grid
        Row(
          children: event.readings.map((r) {
            return Expanded(
              child: Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  decoration: BoxDecoration(
                    color: TWColors.gray.shade50,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: TWColors.gray.shade100),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        r.label,
                        style: TextStyle(
                          color: TWColors.gray.shade400,
                          fontSize: 9,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${r.value} ${r.unit}',
                        style: TextStyle(
                          color: TWColors.gray.shade800,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: _statusBg(r.status),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          r.status,
                          style: TextStyle(
                            color: _statusText(r.status),
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}

// ─── Data Models ─────────────────────────────────────────────────────────────

enum _EventType { pumpOn, sensorRead }

class _SensorReading {
  const _SensorReading({
    required this.label,
    required this.value,
    required this.unit,
    required this.status,
  });
  final String label;
  final String value;
  final String unit;
  final String status;
}

class _CycleEvent {
  const _CycleEvent._({
    required this.type,
    required this.time,
    this.overallStatus,
    this.readings = const [],
  });

  factory _CycleEvent.pumpOn(DateTime time) =>
      _CycleEvent._(type: _EventType.pumpOn, time: time);

  factory _CycleEvent.sensorRead({
    required DateTime time,
    required String overallStatus,
    required List<_SensorReading> readings,
  }) =>
      _CycleEvent._(
        type: _EventType.sensorRead,
        time: time,
        overallStatus: overallStatus,
        readings: readings,
      );

  final _EventType type;
  final DateTime time;
  final String? overallStatus;
  final List<_SensorReading> readings;
}

class _CycleData {
  const _CycleData({
    required this.cycleNumber,
    required this.startTime,
    required this.endTime,
    required this.isRunning,
    required this.events,
  });
  final int cycleNumber;
  final DateTime startTime;
  final DateTime? endTime;
  final bool isRunning;
  final List<_CycleEvent> events;
}
