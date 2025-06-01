//

import 'dart:async';

class ManagedStreamController<T> {
  final Stream<T> Function() streamFactory;

  StreamController<T>? _controller;
  StreamSubscription<T>? _subscription;

  ManagedStreamController({required this.streamFactory});

  StreamController<T> create() {
    _controller = StreamController<T>.broadcast(
      onListen: () {
        _subscription ??= streamFactory().listen(
          _controller!.add,
          onError: _controller!.addError,
          onDone: () => _subscription = null,
        );
      },
      onCancel: () async {
        await _subscription?.cancel();
        _subscription = null;
      },
    );
    return _controller!;
  }

  Future<void> dispose() async {
    await _subscription?.cancel();
    await _controller?.close();
    _subscription = null;
    _controller = null;
  }
}
