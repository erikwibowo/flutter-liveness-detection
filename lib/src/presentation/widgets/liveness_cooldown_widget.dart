import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_liveness_detection_randomized_plugin/src/models/liveness_detection_cooldown.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LivenessCooldownWidget extends StatefulWidget {
  final LivenessDetectionCooldown cooldownState;
  final bool isDarkMode;
  final VoidCallback? onCooldownComplete;
  final int maxFailedAttempts;

  const LivenessCooldownWidget({
    super.key,
    required this.cooldownState,
    this.isDarkMode = true,
    this.onCooldownComplete,
    this.maxFailedAttempts = 3,
  });

  @override
  State<LivenessCooldownWidget> createState() => _LivenessCooldownWidgetState();
}

class _LivenessCooldownWidgetState extends State<LivenessCooldownWidget>
    with WidgetsBindingObserver {
  Timer? _countdownTimer;
  Duration _remainingTime = Duration.zero;
  static const String _remainingTimeKey = 'cooldown_remaining_time';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _loadRemainingTime();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _countdownTimer?.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      _pauseCountdown();
    } else if (state == AppLifecycleState.resumed) {
      _resumeCountdown();
    }
  }

  Future<void> _loadRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    final savedSeconds = prefs.getInt(_remainingTimeKey);

    if (savedSeconds != null) {
      _remainingTime = Duration(seconds: savedSeconds);
    } else {
      _remainingTime = widget.cooldownState.remainingCooldownTime;
    }

    if (mounted) {
      setState(() {});
      _startCountdown();
    }
  }

  Future<void> _saveRemainingTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_remainingTimeKey, _remainingTime.inSeconds);
  }

  void _pauseCountdown() {
    _countdownTimer?.cancel();
    _saveRemainingTime();
  }

  void _resumeCountdown() {
    _loadRemainingTime();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();

    if (_remainingTime.inSeconds <= 0) {
      _clearSavedTime();
      widget.onCooldownComplete?.call();
      return;
    }

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }

      setState(() {
        _remainingTime = _remainingTime - const Duration(seconds: 1);
      });

      _saveRemainingTime();

      if (_remainingTime.inSeconds <= 0) {
        timer.cancel();
        _clearSavedTime();
        widget.onCooldownComplete?.call();
      }
    });
  }

  Future<void> _clearSavedTime() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_remainingTimeKey);
  }

  String _formatDuration(Duration duration) {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Peringatan')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const PhosphorIcon(PhosphorIconsDuotone.timer, size: 80),
              const SizedBox(height: 24),
              const Text(
                'Terlalu Banyak Gagal Verifikasi Keaktifan',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                'Anda telah gagal verifikasi keaktifan ${widget.maxFailedAttempts} kali.\nSilakan tunggu sebelum mencoba lagi.',
                style: const TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Text('Sisa Waktu', style: TextStyle(fontSize: 14)),
                    const SizedBox(height: 8),
                    Text(
                      _formatDuration(_remainingTime),
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Kembali'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
