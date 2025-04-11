final serverURI = 'localhost:8080';

extension Retry<T> on Future<T> Function() {
  Future<T> withRetries(int count) async {
    while (true) {
      try {
        final future = this();
        return await future;
      } catch (e) {
        if (count > 0) {
          count--;
        } else {
          rethrow;
        }
      }
    }
  }
}
