import 'package:flutter/material.dart';
import 'package:flutter_tailwind_colors/flutter_tailwind_colors.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => DashboardPageState();
}

class DashboardPageState extends State<DashboardPage> {
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
                            const SizedBox(height: 16),
                            IntrinsicHeight(
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Expanded(
                                    child: MetricCard(
                                      title: 'Level Air',
                                      value: '--',
                                      unit: '%',
                                      icon: Icons.water_drop_rounded,
                                      iconBg: TWColors.blue.shade100,
                                      iconColor: TWColors.blue.shade700,
                                      status: 'Normal',
                                      statusBg: TWColors.emerald.shade100,
                                      statusText: TWColors.emerald.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: MetricCard(
                                      title: 'pH Air',
                                      value: '--',
                                      unit: 'pH',
                                      icon: Icons.science_rounded,
                                      iconBg: TWColors.violet.shade100,
                                      iconColor: TWColors.violet.shade700,
                                      status: 'Warning',
                                      statusBg: TWColors.amber.shade100,
                                      statusText: TWColors.amber.shade700,
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
                                      value: '--',
                                      unit: 'C',
                                      icon: Icons.thermostat_rounded,
                                      iconBg: TWColors.orange.shade100,
                                      iconColor: TWColors.orange.shade700,
                                      status: 'Normal',
                                      statusBg: TWColors.emerald.shade100,
                                      statusText: TWColors.emerald.shade700,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: MetricCard(
                                      title: 'TDS',
                                      value: '--',
                                      unit: 'ppm',
                                      icon: Icons.tune_rounded,
                                      iconBg: TWColors.cyan.shade100,
                                      iconColor: TWColors.cyan.shade700,
                                      status: 'Warning',
                                      statusBg: TWColors.amber.shade100,
                                      statusText: TWColors.amber.shade700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 16),
                            MetricCard(
                              title: 'Turbidity',
                              value: '--',
                              unit: 'NTU',
                              icon: Icons.blur_on,
                              iconBg: TWColors.sky.shade100,
                              iconColor: TWColors.sky.shade700,
                              status: 'Normal',
                              statusBg: TWColors.emerald.shade100,
                              statusText: TWColors.emerald.shade700,
                            ),

                            // Tambahkan konten dashboard lainnya di sini
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
        ],
      ),
    );
  }
}
