import 'package:flutter/material.dart';
import 'dart:async';

class BreathingSection extends StatefulWidget {
  final bool isDark;
  const BreathingSection({super.key, required this.isDark});

  @override
  State<BreathingSection> createState() => _BreathingSectionState();
}

class _BreathingSectionState extends State<BreathingSection>
    with SingleTickerProviderStateMixin {
  bool _isBreathing = false;
  String _selectedPattern = '';
  String _phase = 'inhale';
  Timer? _timer;
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  final List<Map<String, dynamic>> breathingPatterns = [
    {
      'name': 'Box Breathing',
      'description': 'Inhale, hold, exhale, hold (4s each)',
      'color': Colors.blue,
      'icon': Icons.crop_square_outlined,
      'pattern': {
        'inhale': 4,
        'hold1': 4,
        'exhale': 4,
        'hold2': 4,
      },
    },
    {
      'name': 'Deep Breathing',
      'description': 'Inhale 4s, exhale 6s',
      'color': Colors.green,
      'icon': Icons.waves,
      'pattern': {
        'inhale': 4,
        'hold1': 0,
        'exhale': 6,
        'hold2': 0,
      },
    },
    {
      'name': '4-7-8 Breathing',
      'description': 'Inhale 4s, hold 7s, exhale 8s',
      'color': Colors.purple,
      'icon': Icons.air,
      'pattern': {
        'inhale': 4,
        'hold1': 7,
        'exhale': 8,
        'hold2': 0,
      },
    },
    {
      'name': 'Resonant Breathing',
      'description': 'Inhale 5s, exhale 5s',
      'color': Colors.orange,
      'icon': Icons.circle,
      'pattern': {
        'inhale': 5,
        'hold1': 0,
        'exhale': 5,
        'hold2': 0,
      },
    },
    {
      'name': 'Alternate Nostril',
      'description': 'Inhale left, exhale right',
      'color': Colors.teal,
      'icon': Icons.compare_arrows,
      'pattern': {
        'inhale': 4,
        'hold1': 0,
        'exhale': 4,
        'hold2': 0,
      },
    },
    {
      'name': 'Pursed Lip Breathing',
      'description': 'Inhale 2s, exhale 4s',
      'color': Colors.redAccent,
      'icon': Icons.spa,
      'pattern': {
        'inhale': 2,
        'hold1': 0,
        'exhale': 4,
        'hold2': 0,
      },
    },
    {
      'name': 'Coherent Breathing',
      'description': 'Inhale 6s, exhale 6s',
      'color': Colors.indigo,
      'icon': Icons.blur_circular,
      'pattern': {
        'inhale': 6,
        'hold1': 0,
        'exhale': 6,
        'hold2': 0,
      },
    },
    {
      'name': 'Triangle Breathing',
      'description': 'Inhale, hold, exhale (4s each)',
      'color': Colors.deepOrange,
      'icon': Icons.change_history,
      'pattern': {
        'inhale': 4,
        'hold1': 4,
        'exhale': 4,
        'hold2': 0,
      },
    },
    {
      'name': 'Ujjayi Breathing',
      'description': 'Slow, deep breaths with throat constriction',
      'color': Colors.cyan,
      'icon': Icons.surround_sound,
      'pattern': {
        'inhale': 4,
        'hold1': 0,
        'exhale': 4,
        'hold2': 0,
      },
    },
    {
      'name': 'Sitali Breathing',
      'description': 'Inhale through rolled tongue, exhale nose',
      'color': Colors.lightGreen,
      'icon': Icons.grass,
      'pattern': {
        'inhale': 4,
        'hold1': 0,
        'exhale': 4,
        'hold2': 0,
      },
    },
    {
      'name': 'Skull Shining',
      'description': 'Quick, forceful exhales, passive inhales',
      'color': Colors.amber,
      'icon': Icons.flash_on,
      'pattern': {
        'inhale': 1,
        'hold1': 0,
        'exhale': 1,
        'hold2': 0,
      },
    },
    {
      'name': 'Butterfly Breathing',
      'description': 'Gentle inhale/exhale with arm movement',
      'color': Colors.pinkAccent,
      'icon': Icons.bug_report,
      'pattern': {
        'inhale': 3,
        'hold1': 0,
        'exhale': 3,
        'hold2': 0,
      },
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));

    _opacityAnimation = Tween<double>(
      begin: 0.3,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void startBreathing(Map<String, dynamic> pattern) {
    if (_isBreathing) return;
    setState(() {
      _isBreathing = true;
      _selectedPattern = pattern['name'];
      _phase = 'inhale';
    });
    _startPhase(pattern['pattern']);
  }

  void _startPhase(Map<String, int> pattern) {
    final duration = pattern[_phase] ?? 4;
    _controller.duration = Duration(seconds: duration);

    if (_phase == 'inhale' || _phase == 'exhale') {
      if (_phase == 'inhale') {
        _controller.forward(from: 0);
      } else {
        _controller.reverse(from: 1);
      }
    }

    _timer?.cancel();
    _timer = Timer(Duration(seconds: duration), () {
      if (!mounted) return;
      setState(() {
        switch (_phase) {
          case 'inhale':
            _phase = pattern['hold1']! > 0 ? 'hold1' : 'exhale';
            break;
          case 'hold1':
            _phase = 'exhale';
            break;
          case 'exhale':
            _phase = pattern['hold2']! > 0 ? 'hold2' : 'inhale';
            break;
          case 'hold2':
            _phase = 'inhale';
            break;
        }
      });
      _startPhase(pattern);
    });
  }

  void stopBreathing() {
    _timer?.cancel();
    _controller.reset();
    setState(() {
      _isBreathing = false;
      _selectedPattern = '';
      _phase = 'inhale';
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedPatternData = _isBreathing
        ? breathingPatterns.firstWhere((p) => p['name'] == _selectedPattern)
        : null;

    return Column(
      children: [
        if (_isBreathing) ...[
          _buildBreathingAnimation(selectedPatternData!),
        ] else ...[
          Text(
            'Choose a Breathing Pattern',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF4285F4), // Blue
            ),
          ),
          const SizedBox(height: 24),
          _buildPatternGrid(),
        ],
      ],
    );
  }

  Widget _buildBreathingAnimation(Map<String, dynamic> pattern) {
    final size = MediaQuery.of(context).size;
    final maxRadius = size.width * 0.4;
    final color = pattern['color'] as Color;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          pattern['name'],
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: widget.isDark ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 40),
        Text(
          _phase.toUpperCase(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: color,
          ),
        ),
        const SizedBox(height: 40),
        Center(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Container(
                width: maxRadius * 2 * _scaleAnimation.value,
                height: maxRadius * 2 * _scaleAnimation.value,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(_opacityAnimation.value * 0.3),
                  border: Border.all(
                    color: color.withOpacity(_opacityAnimation.value),
                    width: 2,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton.icon(
          onPressed: stopBreathing,
          icon: const Icon(Icons.stop),
          label: const Text('Stop'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPatternGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.85,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: breathingPatterns.length,
      itemBuilder: (context, index) {
        final pattern = breathingPatterns[index];
        return _buildPatternCard(pattern);
      },
    );
  }

  Widget _buildPatternCard(Map<String, dynamic> pattern) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: () => startBreathing(pattern),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                pattern['icon'] as IconData,
                size: 48,
                color: pattern['color'] as Color,
              ),
              const SizedBox(height: 12),
              Text(
                pattern['name'],
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                pattern['description'],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
