import 'package:flutter/material.dart';
import 'package:signalr_netcore/signalr_client.dart';
import 'package:logging/logging.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import '../screens/call_screen.dart' as basic_call;
import 'dart:async';

class GlobalCallService {
  static final GlobalCallService _instance = GlobalCallService._internal();
  factory GlobalCallService() => _instance;
  GlobalCallService._internal();

  late HubConnection hubConnection;
  final _logger = Logger('GlobalCallService');
  bool _isInitialized = false;
  bool _isCallDialogVisible = false;
  String? _currentCallId;
  Map<String, dynamic>? _currentCallData;
  String? _currentCallerId;
  String? _currentReceiverId;
  String? _currentUserId;

  // Callbacks for UI updates
  Function(String)? onIncomingCall;
  Function()? onCallEnded;
  Function()? onCallRejected;

  Future<void> initialize() async {
    if (_isInitialized) return;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');

    if (token == null) {
      print('No authentication token found for global call service');
      return;
    }

    // Get current user ID from token
    final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    _currentUserId = decodedToken[
            'http://schemas.xmlsoap.org/ws/2005/05/identity/claims/nameidentifier'] ??
        '';

    final hubUrl =
        'http://mohamek-legel.runasp.net/hubs/chathub?access_token=$token';

    hubConnection = HubConnectionBuilder()
        .withUrl(
          hubUrl,
          options: HttpConnectionOptions(
            logger: _logger,
            logMessageContent: true,
            skipNegotiation: false,
            accessTokenFactory: () => Future.value(token),
          ),
        )
        .withAutomaticReconnect()
        .build();

    // Set up call event handlers
    hubConnection.on("IncomingCall", _onIncomingCall);
    hubConnection.on("CallStarted", _onCallStarted);
    hubConnection.on("CallEnded", _onCallEnded);
    hubConnection.on("CallAccepted", _onCallAccepted);
    hubConnection.on("CallRejected", _onCallRejected);
    hubConnection.on("ReceiveOffer", _onReceiveOffer);
    hubConnection.on("ReceiveAnswer", _onReceiveAnswer);
    hubConnection.on("ReceiveIceCandidate", _onReceiveIceCandidate);

    try {
      print('Starting global SignalR connection...');
      await hubConnection.start();

      if (hubConnection.state == HubConnectionState.Connected) {
        print('✅ Global SignalR connected successfully!');
        _isInitialized = true;
      }
    } catch (e) {
      print('Error connecting to global SignalR: $e');
    }
  }

  void _onIncomingCall(List<Object?>? arguments) {
    print(
        '📞 Global incoming call: arguments = ${arguments != null && arguments.isNotEmpty ? arguments[0] : 'No data'}');

    if (_isCallDialogVisible) return; // Prevent multiple dialogs

    if (arguments != null && arguments.isNotEmpty && arguments[0] is Map) {
      final callData = Map<String, dynamic>.from(arguments[0] as Map);
      _currentCallId = callData['id']?.toString();
      _currentCallData = callData;
      _currentCallerId = callData['callerId']?.toString();
      _currentReceiverId = callData['receiverId']?.toString();
      final callerName = callData['callerName']?.toString() ?? 'Unknown';
      final consultationId = callData['consultationId']?.toString() ?? '';
      final delegationId = callData['delegationId']?.toString() ?? '';
      final callerImageUrl = callData['callerImageUrl']?.toString() ?? '';

      _isCallDialogVisible = true;
      print('📞 Received global incoming call with ID: $_currentCallId');
      print(
          '📞 Caller ID: $_currentCallerId, Receiver ID: $_currentReceiverId');

      // Show call screen using navigator key
      _showIncomingCallScreen(
          callerName, callerImageUrl, consultationId, delegationId);
    }
  }

  void _showIncomingCallScreen(String callerName, String callerImageUrl,
      String consultationId, String delegationId) {
    // Use a global navigator key to show the call screen from anywhere
    final context = GlobalCallNavigator.navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).push(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => basic_call.CallScreen(
            callerName: callerName,
            initialState: basic_call.CallState.incoming,
            avatarUrl: callerImageUrl,
            onAccept: () {
              print(
                  'Accepting global call with consultationId: $consultationId, delegationId: $delegationId');
              acceptCall(consultationId, delegationId);
              _isCallDialogVisible = false;
            },
            onReject: () {
              print(
                  'Rejecting global call with consultationId: $consultationId, delegationId: $delegationId');
              rejectCall(consultationId, delegationId);
              Navigator.of(context).pop();
              _isCallDialogVisible = false;
            },
            onEnd: () {
              print(
                  'Ending global incoming call with callId: ${_currentCallId ?? ''}');
              endCall(_currentCallId ?? '');
              Navigator.of(context).pop();
              _isCallDialogVisible = false;
            },
          ),
        ),
      );
    }
  }

  void _onCallStarted(List<Object?>? arguments) {
    print(
        '📞 Global call started: arguments = ${arguments != null && arguments.isNotEmpty ? arguments[0] : 'No data'}');
    if (arguments != null && arguments.isNotEmpty && arguments[0] is Map) {
      final callData = Map<String, dynamic>.from(arguments[0] as Map);
      _currentCallId = callData['id']?.toString();
      _currentCallData = callData;
      _currentCallerId = callData['callerId']?.toString();
      _currentReceiverId = callData['receiverId']?.toString();
      print('📞 Global outgoing call started with ID: $_currentCallId');
      print(
          '📞 Caller ID: $_currentCallerId, Receiver ID: $_currentReceiverId');
    }
  }

  void _onCallAccepted(List<Object?>? arguments) {
    print(
        '✅ Global call accepted: arguments = ${arguments != null && arguments.isNotEmpty ? arguments[0] : 'No data'}');

    if (arguments != null && arguments.isNotEmpty) {
      final acceptedCallId = arguments[0]?.toString();
      if (acceptedCallId != null && acceptedCallId.isNotEmpty) {
        _currentCallId = acceptedCallId;
        print('✅ Global call accepted with ID: $_currentCallId');
      }
    }

    final callerName = _currentCallData?['callerName']?.toString() ?? 'Unknown';
    final callerImageUrl =
        _currentCallData?['callerImageUrl']?.toString() ?? '';

    final context = GlobalCallNavigator.navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => basic_call.CallScreen(
            callerName: callerName,
            initialState: basic_call.CallState.connected,
            avatarUrl: callerImageUrl,
            onAccept: () {}, // Not used in connected state
            onReject: () {}, // Not used in connected state
            onEnd: () {
              print(
                  'Ending global connected call with callId: ${_currentCallId ?? ''}');
              endCall(_currentCallId ?? '');
              Navigator.of(context).pop();
              _isCallDialogVisible = false;
            },
          ),
        ),
      );
    }
  }

  void _onCallEnded(List<Object?>? arguments) {
    print(
        '📴 Global call ended: arguments = ${arguments != null && arguments.isNotEmpty ? arguments[0] : 'No data'}');
    _isCallDialogVisible = false;
    _currentCallId = null;
    _currentCallData = null;
    _currentCallerId = null;
    _currentReceiverId = null;

    final context = GlobalCallNavigator.navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context, rootNavigator: true)
          .popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم إنهاء المكالمة')),
      );
    }
  }

  void _onCallRejected(List<Object?>? arguments) {
    print(
        '❌ Global call rejected: arguments = ${arguments != null && arguments.isNotEmpty ? arguments[0] : 'No data'}');
    _isCallDialogVisible = false;
    _currentCallId = null;
    _currentCallData = null;
    _currentCallerId = null;
    _currentReceiverId = null;

    final context = GlobalCallNavigator.navigatorKey.currentContext;
    if (context != null) {
      Navigator.of(context, rootNavigator: true)
          .popUntil((route) => route.isFirst);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم رفض المكالمة')),
      );
    }
  }

  void _onReceiveOffer(List<Object?>? arguments) {
    print(
        '📡 Global received offer: arguments = ${arguments != null && arguments.isNotEmpty ? arguments[0] : 'No data'}');
    // TODO: Handle WebRTC offer
  }

  void _onReceiveAnswer(List<Object?>? arguments) {
    print(
        '📡 Global received answer: arguments = ${arguments != null && arguments.isNotEmpty ? arguments[0] : 'No data'}');
    // TODO: Handle WebRTC answer
  }

  void _onReceiveIceCandidate(List<Object?>? arguments) {
    print(
        '❄️ Global received ICE candidate: arguments = ${arguments != null && arguments.isNotEmpty ? arguments[0] : 'No data'}');
    // TODO: Handle ICE candidate
  }

  // Call methods
  Future<void> startCall({
    String? consultationId,
    String? delegationId,
    required String type,
  }) async {
    try {
      if (hubConnection.state != HubConnectionState.Connected) {
        print(
            '⚠️ Global SignalR not connected. Current state: ${hubConnection.state}');
        return;
      }

      print('Starting global call with:');
      print('- consultationId: ${consultationId ?? 'null'}');
      print('- delegationId: ${delegationId ?? 'null'}');
      print('- type: $type');
      print('- currentUserId: $_currentUserId');

      if (consultationId == null || consultationId.isEmpty) {
        throw Exception('consultationId is required');
      }

      await hubConnection.invoke('StartCall',
          args: [consultationId, delegationId ?? '', type]);
      print('Global StartCall invoked successfully');
    } catch (e) {
      print('Error invoking global StartCall: $e');
    }
  }

  Future<void> acceptCall(String consultationId, String delegationId) async {
    try {
      print(
          'Accepting global call with consultationId: $consultationId, delegationId: $delegationId');
      await hubConnection
          .invoke('AcceptCall', args: [consultationId, delegationId]);
      print('Global AcceptCall invoked successfully');
    } catch (e) {
      print('Error invoking global AcceptCall: $e');
    }
  }

  Future<void> rejectCall(String consultationId, String delegationId) async {
    try {
      print(
          'Rejecting global call with consultationId: $consultationId, delegationId: $delegationId');
      await hubConnection
          .invoke('RejectCall', args: [consultationId, delegationId]);
      print('Global RejectCall invoked successfully');
    } catch (e) {
      print('Error invoking global RejectCall: $e');
    }
  }

  Future<void> endCall([String? callId]) async {
    try {
      // Use provided callId or fall back to stored callId
      final callIdToUse = callId ?? _currentCallId;

      print('Ending global call with callId: $callIdToUse');
      if (callIdToUse == null || callIdToUse.isEmpty) {
        print('⚠️ Attempting to end global call with empty callId');
        print('Current stored callId: $_currentCallId');
        return;
      }

      await hubConnection.invoke('EndCall', args: [callIdToUse]);
      print('Global EndCall invoked successfully');

      _currentCallId = null;
      _currentCallerId = null;
      _currentReceiverId = null;
      _currentCallData = null;
    } catch (e) {
      print('Error invoking global EndCall: $e');
    }
  }

  void dispose() {
    hubConnection.stop();
    _isInitialized = false;
  }
}

// Global navigator key for showing call screens from anywhere
class GlobalCallNavigator {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();
}
