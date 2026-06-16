import 'package:flutter/cupertino.dart';
import 'package:flutter_liveness_detection_randomized_plugin/index.dart';
import 'package:flutter_liveness_detection_randomized_plugin/src/presentation/widgets/circular_progress_widget/circular_progress_widget.dart';
import 'package:phosphoricons_flutter/phosphoricons_flutter.dart';

class LivenessDetectionStepOverlayWidget extends StatefulWidget {
  final List<LivenessDetectionStepItem> steps;
  final VoidCallback onCompleted;
  final Widget camera;
  final CameraController? cameraController;
  final bool isFaceDetected;
  final bool showCurrentStep;
  final bool isDarkMode;
  final bool showDurationUiText;
  final int? duration;

  const LivenessDetectionStepOverlayWidget({
    super.key,
    required this.steps,
    required this.onCompleted,
    required this.camera,
    required this.cameraController,
    required this.isFaceDetected,
    this.showCurrentStep = false,
    this.isDarkMode = true,
    this.showDurationUiText = false,
    this.duration,
  });

  @override
  State<LivenessDetectionStepOverlayWidget> createState() =>
      LivenessDetectionStepOverlayWidgetState();
}

class LivenessDetectionStepOverlayWidgetState
    extends State<LivenessDetectionStepOverlayWidget> {
  int get currentIndex => _currentIndex;

  bool _isLoading = false;
  int _currentIndex = 0;
  double _currentStepIndicator = 0;
  late final PageController _pageController;

  bool _pageViewVisible = false;
  Timer? _countdownTimer;
  int _remainingDuration = 0;

  static const double _indicatorMaxStep = 100;
  static const double _heightLine = 25;

  double _getStepIncrement(int stepLength) {
    return 100 / stepLength;
  }

  String get stepCounter => "$_currentIndex/${widget.steps.length}";

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _pageViewVisible = true;
      });
    });
    debugPrint('showCurrentStep ${widget.showCurrentStep}');
  }

  void _initializeControllers() {
    _pageController = PageController(initialPage: 0);
  }

  void _initializeTimer() {
    if (widget.duration != null && widget.showDurationUiText) {
      _remainingDuration = widget.duration!;
      _startCountdownTimer();
    }
  }

  void _startCountdownTimer() {
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingDuration > 0) {
        setState(() {
          _remainingDuration--;
        });
      } else {
        _countdownTimer?.cancel();
      }
    });
  }

  CircularProgressWidget _buildCircularIndicator() {
    double scale = 1.0;
    if (widget.cameraController != null &&
        widget.cameraController!.value.isInitialized) {
      final cameraAspectRatio = widget.cameraController!.value.aspectRatio;
      const containerAspectRatio = 1.0;
      scale = cameraAspectRatio / containerAspectRatio;
      if (scale < 1.0) {
        scale = 1.0 / scale;
      }
    }

    return CircularProgressWidget(
      unselectedColor: Theme.of(context).colorScheme.onSurface.withAlpha(100),
      selectedColor: Theme.of(context).colorScheme.primary,
      heightLine: _heightLine,
      current: _currentStepIndicator,
      maxStep: _indicatorMaxStep,
      child: Transform.scale(
        scale: scale,
        child: Center(child: widget.camera),
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    _countdownTimer?.cancel();
    super.dispose();
  }

  Future<void> nextPage() async {
    if (_isLoading) return;

    if (_currentIndex + 1 <= widget.steps.length - 1) {
      await _handleNextStep();
    } else {
      await _handleCompletion();
    }
  }

  Future<void> _handleNextStep() async {
    _showLoader();
    await Future.delayed(const Duration(milliseconds: 100));
    await _pageController.nextPage(
      duration: const Duration(milliseconds: 1),
      curve: Curves.easeIn,
    );
    await Future.delayed(const Duration(seconds: 1));
    _hideLoader();
    _updateState();
  }

  Future<void> _handleCompletion() async {
    _updateState();
    await Future.delayed(const Duration(milliseconds: 500));
    widget.onCompleted();
  }

  void _updateState() {
    if (mounted) {
      setState(() {
        _currentIndex++;
        _currentStepIndicator += _getStepIncrement(widget.steps.length);
      });
    }
  }

  void reset() {
    _pageController.jumpToPage(0);
    if (mounted) {
      setState(() {
        _currentIndex = 0;
        _currentStepIndicator = 0;
      });
    }
  }

  void _showLoader() {
    if (mounted) setState(() => _isLoading = true);
  }

  void _hideLoader() {
    if (mounted) setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Deteksi Keaktifan'),
        actions: [
          if (widget.showCurrentStep)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Center(
                child: Text(
                  stepCounter,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisSize: MainAxisSize.max,
      children: [
        if (widget.showDurationUiText)
          Text(
            _getRemainingTimeText(_remainingDuration),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        const SizedBox(height: 16),
        _buildCircularCamera(),
        const SizedBox(height: 16),
        _buildFaceDetectionStatus(),
        const SizedBox(height: 16),
        Visibility(
          visible: _pageViewVisible,
          replacement: const CircularProgressIndicator.adaptive(),
          child: _buildStepPageView(),
        ),
        const SizedBox(height: 16),
        _buildLoader(),
      ],
    );
  }

  Widget _buildCircularCamera() {
    return SizedBox(
      height: 300,
      width: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1000),
        child: _buildCircularIndicator(),
      ),
    );
  }

  String _getRemainingTimeText(int duration) {
    int minutes = duration ~/ 60;
    int seconds = duration % 60;
    return "${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
  }

  Widget _buildFaceDetectionStatus() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      spacing: 4,
      children: [
        PhosphorIcon(
          PhosphorIconsDuotone.scanSmiley,
          color: widget.isFaceDetected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
          size: 24,
        ),
        Text(
          widget.isFaceDetected ? 'Wajah terdeteksi' : 'Wajah tidak terdeteksi',
          style: TextStyle(
            color: widget.isFaceDetected
                ? Theme.of(context).colorScheme.primary
                : Theme.of(context).colorScheme.error,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStepPageView() {
    return SizedBox(
      height: MediaQuery.of(context).size.height / 10,
      width: MediaQuery.of(context).size.width,
      child: AbsorbPointer(
        absorbing: true,
        child: PageView.builder(
          controller: _pageController,
          itemCount: widget.steps.length,
          itemBuilder: _buildStepItem,
        ),
      ),
    );
  }

  Widget _buildStepItem(BuildContext context, int index) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Text(
        widget.steps[index].title,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onPrimaryContainer,
          fontSize: 24,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return _isLoading
        ? const Center(child: CupertinoActivityIndicator())
        : const SizedBox.shrink();
  }
}
