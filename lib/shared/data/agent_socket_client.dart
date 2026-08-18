import 'dart:async';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../core/config/environment.dart';

class AgentSocketClient {
  final _events = StreamController<AgentSocketEvent>.broadcast();
  io.Socket? _socket;
  Stream<AgentSocketEvent> get events => _events.stream;
  void connect(String token) {
    _socket ??=
        io.io(
            Environment.websocketUrl,
            io.OptionBuilder()
                .setTransports(['websocket'])
                .setAuth({'token': token})
                .disableAutoConnect()
                .build(),
          )
          ..onAny((event, data) => _events.add(AgentSocketEvent(event, data)))
          ..connect();
  }

  void disconnect() {
    _socket?.dispose();
    _socket = null;
  }
}

class AgentSocketEvent {
  const AgentSocketEvent(this.name, this.data);
  final String name;
  final dynamic data;
}
