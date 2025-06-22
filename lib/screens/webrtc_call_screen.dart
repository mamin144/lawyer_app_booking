import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';

enum CallState {
  outgoing,
  incoming,
  connecting,
  connected,
  ended,
  failed,
}

class WebRTCCallScreen extends StatefulWidget {
  final String callerName;
  final String? avatarUrl;
  final CallState initialState;
  final String consultationId;
  final String delegationId;
  final HubConnection hubConnection;
  final VoidCallback onAccept;
  final VoidCallback onReject;
  final VoidCallback onEnd;

  const WebRTCCallScreen({
    super.key,
    required this.callerName,
    this.avatarUrl,
    required this.initialState,
    required this.consultationId,
    required this.delegationId,
    required this.hubConnection,
    required this.onAccept,
    required this.onReject,
    required this.onEnd,
  });

  @override
  State<WebRTCCallScreen> createState() => _WebRTCCallScreenState();
}

class _WebRTCCallScreenState extends State<WebRTCCallScreen>
    with SingleTickerProviderStateMixin {
  late CallState _currentState;
  Timer? _timer;
  int _seconds = 0;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // WebRTC state
  bool _isMuted = false;
  bool _isSpeakerOn = false;
  bool _isCameraOff = false;
  String _connectionStatus = 'Initializing...';

  @override
  void initState() {
    super.initState();
    _currentState = widget.initialState;

    // Initialize pulse animation
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

    // Set up WebRTC event listeners
    _setupWebRTCEventListeners();
  }

  void _setupWebRTCEventListeners() {
    // Listen for WebRTC signaling events
    widget.hubConnection.on("ReceiveOffer", _onReceiveOffer);
    widget.hubConnection.on("ReceiveAnswer", _onReceiveAnswer);
    widget.hubConnection.on("ReceiveIceCandidate", _onReceiveIceCandidate);
  }

  void _onReceiveOffer(List<Object?>? arguments) {
    print('📡 Received WebRTC offer: $arguments');
    if (arguments != null && arguments.isNotEmpty) {
      final data = arguments[0] as Map<String, dynamic>;
      final offer = data['offer'] as String;
      final senderId = data['senderId'] as String;

      setState(() {
        _connectionStatus = 'Processing offer...';
      });

      // TODO: Handle WebRTC offer
      _handleWebRTCOffer(offer, senderId);
    }
  }

  void _onReceiveAnswer(List<Object?>? arguments) {
    print('📡 Received WebRTC answer: $arguments');
    if (arguments != null && arguments.isNotEmpty) {
      final data = arguments[0] as Map<String, dynamic>;
      final answer = data['answer'] as String;
      final senderId = data['senderId'] as String;

      setState(() {
        _connectionStatus = 'Processing answer...';
      });

      // TODO: Handle WebRTC answer
      _handleWebRTCAnswer(answer, senderId);
    }
  }

  void _onReceiveIceCandidate(List<Object?>? arguments) {
    print('❄️ Received ICE candidate: $arguments');
    if (arguments != null && arguments.isNotEmpty) {
      final data = arguments[0] as Map<String, dynamic>;
      final candidate = data['candidate'] as String;
      final senderId = data['senderId'] as String;

      // TODO: Handle ICE candidate
      _handleIceCandidate(candidate, senderId);
    }
  }

  void _handleWebRTCOffer(String offer, String senderId) {
    // TODO: Implement WebRTC offer handling
    print('Handling WebRTC offer from $senderId: $offer');
    setState(() {
      _connectionStatus = 'Offer received, creating answer...';
    });
  }

  void _handleWebRTCAnswer(String answer, String senderId) {
    // TODO: Implement WebRTC answer handling
    print('Handling WebRTC answer from $senderId: $answer');
    setState(() {
      _connectionStatus = 'Answer received, establishing connection...';
    });
  }

  void _handleIceCandidate(String candidate, String senderId) {
    // TODO: Implement ICE candidate handling
    print('Handling ICE candidate from $senderId: $candidate');
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
      case CallState.connecting:
        return Text(
          _connectionStatus,
          style: const TextStyle(color: Colors.white70, fontSize: 18),
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
      case CallState.failed:
        return const Text(
          'فشل الاتصال',
          style: TextStyle(color: Colors.red, fontSize: 18),
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
                  _currentState = CallState.connecting;
                  _pulseController.stop();
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
      case CallState.connecting:
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
              label: 'إلغاء',
            ),
          ],
        );
      case CallState.connected:
        return Column(
          children: [
            // Connection status
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Text(
                _connectionStatus,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
            // Call controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildCallButton(
                  onPressed: () {
                    setState(() {
                      _isMuted = !_isMuted;
                    });
                    // TODO: Implement mute functionality
                  },
                  color: _isMuted ? Colors.red : Colors.grey,
                  icon: _isMuted ? Icons.mic_off : Icons.mic,
                  label: _isMuted ? 'إلغاء كتم' : 'كتم',
                ),
                const SizedBox(width: 20),
                _buildCallButton(
                  onPressed: () {
                    setState(() {
                      _isSpeakerOn = !_isSpeakerOn;
                    });
                    // TODO: Implement speaker functionality
                  },
                  color: _isSpeakerOn ? Colors.blue : Colors.grey,
                  icon: _isSpeakerOn ? Icons.volume_up : Icons.volume_down,
                  label: _isSpeakerOn ? 'إغلاق مكبر' : 'مكبر الصوت',
                ),
                const SizedBox(width: 20),
                _buildCallButton(
                  onPressed: () {
                    setState(() {
                      _isCameraOff = !_isCameraOff;
                    });
                    // TODO: Implement camera functionality
                  },
                  color: _isCameraOff ? Colors.red : Colors.grey,
                  icon: _isCameraOff ? Icons.videocam_off : Icons.videocam,
                  label: _isCameraOff ? 'تشغيل الكاميرا' : 'إغلاق الكاميرا',
                ),
              ],
            ),
            const SizedBox(height: 20),
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
      case CallState.failed:
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
