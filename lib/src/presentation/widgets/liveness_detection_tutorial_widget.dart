import 'package:flutter_liveness_detection_randomized_plugin/index.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class LivenessDetectionTutorialScreen extends StatefulWidget {
  final VoidCallback onStartTap;
  final bool isDarkMode;
  final int? duration;
  const LivenessDetectionTutorialScreen({
    super.key,
    required this.onStartTap,
    this.isDarkMode = false,
    required this.duration,
  });

  @override
  State<LivenessDetectionTutorialScreen> createState() =>
      _LivenessDetectionTutorialScreenState();
}

class _LivenessDetectionTutorialScreenState
    extends State<LivenessDetectionTutorialScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Petunjuk deteksi keaktifan')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const ListTile(
                      leading: CircleAvatar(child: Text('1')),
                      subtitle: Text(
                        "Pastikan area sekitar Anda memiliki pencahayaan yang cukup untuk hasil terbaik",
                      ),
                      title: Text("Pencahayaan yang Cukup"),
                    ),
                    const ListTile(
                      leading: CircleAvatar(child: Text('2')),
                      subtitle: Text(
                        "Pastikan Anda memandang langsung ke kamera selama proses verifikasi",
                      ),
                      title: Text("Pandangan ke Kamera"),
                    ),
                    ListTile(
                      leading: const CircleAvatar(child: Text('3')),
                      subtitle: Text(
                        "Batas waktu yang diberikan untuk proses verifikasi sistem deteksi keaktifan adalah ${widget.duration ?? 45} detik",
                      ),
                      title: const Text("Batas Waktu Verifikasi"),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: FilledButton(
                onPressed: () => widget.onStartTap(),
                child: const Row(
                  spacing: 10,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    PhosphorIcon(PhosphorIconsDuotone.scanSmiley, size: 24),
                    Text("Mulai Deteksi Keaktifan"),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
