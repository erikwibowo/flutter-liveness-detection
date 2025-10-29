import 'package:flutter_liveness_detection_randomized_plugin/index.dart';

class LivenessDetectionTutorialScreen extends StatefulWidget {
  final VoidCallback onStartTap;
  final int? duration;
  const LivenessDetectionTutorialScreen(
      {super.key, required this.onStartTap, required this.duration});

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
      appBar: AppBar(
        title: const Text("Verifikasi Keaktifan"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          spacing: 12,
          children: [
            Card(
              child: ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: CircleAvatar(
                        child: Text('1',
                            style: Theme.of(context).textTheme.titleMedium)),
                    subtitle: const Text(
                      "Pastikan pencahayaan di sekitar cukup terang agar wajah dapat terdeteksi dengan baik",
                    ),
                    title: Text("Pencahayaan",
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                        child: Text('2',
                            style: Theme.of(context).textTheme.titleMedium)),
                    subtitle: const Text(
                        "Pegang ponsel sejajar mata dan lihat lurus ke kamera",
                        style: TextStyle()),
                    title: Text("Pandangan Lurus",
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  ListTile(
                    leading: CircleAvatar(
                        child: Text('3',
                            style: Theme.of(context).textTheme.titleMedium)),
                    subtitle: Text(
                      "Batas waktu yang diberikan untuk proses verifikasi sistem deteksi keaktifan adalah ${widget.duration ?? 45} detik",
                    ),
                    title: Text("Batas Waktu",
                        style: Theme.of(context).textTheme.titleMedium),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: FilledButton.icon(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      icon: const Icon(Icons.camera_alt_outlined),
                      onPressed: () => widget.onStartTap(),
                      label: const Text(
                        "Mulai Verifikasi keaktifan",
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  spacing: 8,
                  children: [
                    CircleAvatar(
                      child: Icon(
                        Icons.info_outline,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        "Layar informasi verifikasi keaktifan dapat dinonaktifkan pada pengaturan aplikasi.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
