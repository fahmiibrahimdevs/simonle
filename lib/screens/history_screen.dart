import 'package:flutter/material.dart';
import 'package:flutter_tailwind_colors/flutter_tailwind_colors.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
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
                            Container(
                              height: 120,
                              decoration: BoxDecoration(
                                color: TWColors.gray.shade50,
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: TWColors.gray.shade100,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                'Konten History akan ditaruh di sini',
                                style: TextStyle(
                                  color: TWColors.gray.shade500,
                                  fontWeight: FontWeight.w500,
                                  fontSize: 12,
                                ),
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
