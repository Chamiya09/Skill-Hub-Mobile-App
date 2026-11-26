import 'dart:math' as math;

import 'package:flutter/material.dart';

const _emerald = Color(0xFF059669);
const _emeraldDark = Color(0xFF047857);
const _ink = Color(0xFF0F172A);
const _track = Color(0xFFE2E8F0);

class SkillHubLoadingIndicator extends StatefulWidget {
  const SkillHubLoadingIndicator({super.key, this.message});

  final String? message;

  @override
  State<SkillHubLoadingIndicator> createState() =>
      _SkillHubLoadingIndicatorState();
}

class _SkillHubLoadingIndicatorState extends State<SkillHubLoadingIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _markController;
  late final AnimationController _progressController;
  bool? _animationsDisabled;

  @override
  void initState() {
    super.initState();
    _markController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final animationsDisabled = MediaQuery.disableAnimationsOf(context);
    if (_animationsDisabled == animationsDisabled) return;
    _animationsDisabled = animationsDisabled;

    if (animationsDisabled) {
      _markController
        ..stop()
        ..value = 0;
      _progressController
        ..stop()
        ..value = 0;
    } else {
      _markController.repeat();
      _progressController.repeat();
    }
  }

  @override
  void dispose() {
    _markController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      liveRegion: true,
      label: widget.message ?? 'Loading SkillHub',
      child: AnimatedBuilder(
        animation: Listenable.merge([_markController, _progressController]),
        builder: (context, _) {
          final phase = _markController.value;
          final progress = Curves.easeInOut.transform(_progressController.value);
          final markOffset = math.sin(phase * math.pi * 2) * 3;

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 70,
                height: 70,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: 0.94 + (phase * 0.18),
                      child: Opacity(
                        opacity: (1 - phase) * 0.75,
                        child: Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: const Color(0x33059669),
                            ),
                            borderRadius: BorderRadius.circular(21),
                          ),
                        ),
                      ),
                    ),
                    Transform.translate(
                      offset: Offset(0, -markOffset),
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(color: _track),
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Color(0x140F172A),
                              blurRadius: 24,
                              offset: Offset(0, 8),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.auto_awesome_outlined,
                          color: _emeraldDark,
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              const Text.rich(
                TextSpan(
                  style: TextStyle(
                    color: _ink,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                  children: [
                    TextSpan(text: 'Skill'),
                    TextSpan(
                      text: 'Hub',
                      style: TextStyle(color: _emeraldDark),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: SizedBox(
                  width: 168,
                  height: 3,
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: ColoredBox(color: _track),
                      ),
                      FractionalTranslation(
                        translation: Offset(-1.1 + (progress * 3.6), 0),
                        child: const FractionallySizedBox(
                          widthFactor: 0.42,
                          heightFactor: 1,
                          child: ColoredBox(color: _emerald),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (widget.message != null) ...[
                const SizedBox(height: 16),
                Text(
                  widget.message!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}
