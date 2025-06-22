import 'dart:async';
import 'package:flutter/material.dart';

enum CallState {
  outgoing,
  incoming,
  connected,
  ended,
}

class CallScreen extends StatefulWidget {
  final String callerName;
  final String? avatarUrl;
  final CallState initialState;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onEnd;

  const CallScreen({
    super.key,
    required this.callerName,
    this.avatarUrl,
    required this.initialState,
    required this.onAccept,
    required this.onReject,
    required this.onEnd,
  });

  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen>
    with SingleTickerProviderStateMixin {
  late CallState _currentState;
  Timer? _timer;
  int _seconds = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;

    // Initialize pulse animation for ringing effect
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    if (_currentState == CallState.incoming ||
        _currentState == CallState.outgoing) {
      _pulseController.repeat(reverse: true);
    }

    if (_currentState == CallState.connected) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _seconds++;
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final secs = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  Widget _buildCallStateIndicator() {
    switch (_currentState) {
      case CallState.incoming:
        return const Text(
          'مكالمة واردة',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        );
      case CallState.outgoing:
        return const Text(
          'جاري الاتصال...',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        );
      case CallState.connected:
        return Text(
          _formatDuration(_seconds),
          style: const TextStyle(color: Colors.white70, fontSize: 18),
        );
      case CallState.ended:
        return const Text(
          'انتهت المكالمة',
          style: TextStyle(color: Colors.white70, fontSize: 18),
        );
    }
  }

  Widget _buildCallControls() {
    switch (_currentState) {
      case CallState.incoming:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCallButton(
              onPressed: () {
                setState(() {
                  _currentState = CallState.connected;
                  _pulseController.stop();
                  _startTimer();
                });
                widget.onAccept();
              },
              color: Colors.green,
              icon: Icons.call,
              label: 'قبول',
            ),
            const SizedBox(width: 48),
            _buildCallButton(
              onPressed: () {
                setState(() {
                  _currentState = CallState.ended;
                });
                widget.onReject();
              },
              color: Colors.red,
              icon: Icons.call_end,
              label: 'رفض',
            ),
          ],
        );
      case CallState.outgoing:
      case CallState.connected:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildCallButton(
              onPressed: () {
                setState(() {
                  _currentState = CallState.ended;
                });
                widget.onEnd();
              },
              color: Colors.red,
              icon: Icons.call_end,
              label: 'إنهاء',
            ),
          ],
        );
      case CallState.ended:
        return const SizedBox.shrink();
    }
  }

  Widget _buildCallButton({
    required VoidCallback onPressed,
    required Color color,
    required IconData icon,
    required String label,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        FloatingActionButton(
          backgroundColor: color,
          onPressed: onPressed,
          child: Icon(icon, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(color: Colors.white70),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: SafeArea(
        child: Stack(
          children: [
            // Background gradient
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue.withOpacity(0.2),
                    Colors.black.withOpacity(0.8),
                  ],
                ),
              ),
            ),
            // Call content
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const SizedBox(height: 48),
                // Avatar and name section
                Column(
                  children: [
                    AnimatedBuilder(
                      animation: _pulseAnimation,
                      builder: (context, child) {
                        return Transform.scale(
                          scale: _currentState == CallState.connected
                              ? 1.0
                              : _pulseAnimation.value,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: Colors.white.withOpacity(0.5),
                                width: 2,
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 60,
                              backgroundColor: Colors.grey[800],
                              backgroundImage: widget.avatarUrl != null
                                  ? NetworkImage(widget.avatarUrl!)
                                  : null,
                              child: widget.avatarUrl == null
                                  ? const Icon(Icons.person,
                                      size: 60, color: Colors.white70)
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),
                    Text(
                      widget.callerName,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildCallStateIndicator(),
                  ],
                ),
                // Call controls
                Padding(
                  padding: const EdgeInsets.only(bottom: 48),
                  child: _buildCallControls(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
