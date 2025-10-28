import 'package:flutter_liveness_detection_randomized_plugin/index.dart';
import 'package:flutter_liveness_detection_randomized_plugin/src/presentation/widgets/circular_progress_widget/circular_progress_widget.dart';

class LivenessDetectionStepOverlayWidget extends StatefulWidget {
  final List<LivenessDetectionStepItem> steps;
  final VoidCallback onCompleted;
  final Widget camera;
  final CameraController? cameraController;
  final bool isFaceDetected;
  final bool showCurrentStep;
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
  CircularProgressWidget? _circularProgressWidget;

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
      unselectedColor: Theme.of(context).colorScheme.onSurface.withAlpha(51),
      selectedColor: Theme.of(context).colorScheme.primary,
      heightLine: _heightLine,
      current: _currentStepIndicator,
      maxStep: _indicatorMaxStep,
      child: Transform.scale(
        scale: scale,
        child: Center(
          child: widget.camera,
        ),
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
        _circularProgressWidget = _buildCircularIndicator();
      });
    }
  }

  void reset() {
    _pageController.jumpToPage(0);
    if (mounted) {
      setState(() {
        _currentIndex = 0;
        _currentStepIndicator = 0;
        _circularProgressWidget = _buildCircularIndicator();
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
        title: const Text("Verifikasi Keaktifan"),
      ),
      body: Container(
        margin: const EdgeInsets.all(12),
        height: double.infinity,
        width: double.infinity,
        child: Stack(
          children: [
            _buildBody(),
          ],
        ),
      ),
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
            style: Theme.of(context).textTheme.titleLarge,
          ),
        const SizedBox(height: 16),
        _buildCircularCamera(),
        const SizedBox(height: 16),
        _buildFaceDetectionStatus(),
        Visibility(
          visible: _pageViewVisible,
          replacement: const CircularProgressIndicator.adaptive(),
          child: _buildStepPageView(),
        ),
        _buildLoader(),
      ],
    );
  }

  Widget _buildCircularCamera() {
    // Ensure circular progress widget is built with current context
    _circularProgressWidget ??= _buildCircularIndicator();

    return SizedBox(
      height: 300,
      width: 300,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(1000),
        child: _circularProgressWidget!,
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
      children: [
        Icon(
          widget.isFaceDetected
              ? Icons.sentiment_satisfied_alt_rounded
              : Icons.sentiment_dissatisfied_rounded,
          color: widget.isFaceDetected
              ? Theme.of(context).colorScheme.primary
              : Theme.of(context).colorScheme.error,
        ),
        const SizedBox(width: 8),
        Text(
          widget.isFaceDetected ? 'Wajah Terdeteksi' : 'Wajah Tidak Terdeteksi',
          style: widget.isFaceDetected
              ? TextStyle(color: Theme.of(context).colorScheme.primary)
                  .copyWith(fontWeight: FontWeight.bold)
              : TextStyle(color: Theme.of(context).colorScheme.error)
                  .copyWith(fontWeight: FontWeight.bold),
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
      padding: const EdgeInsets.all(10),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        margin: const EdgeInsets.symmetric(horizontal: 30),
        padding: const EdgeInsets.all(10),
        child: Text(
          widget.steps[index].title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildLoader() {
    return Center(
      child: SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator.adaptive(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(
            _isLoading
                ? Colors.transparent
                : Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
    );
  }
}
