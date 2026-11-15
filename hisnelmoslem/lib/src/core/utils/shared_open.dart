/// Runs an async open function once for everyone who asks while it is still running.
///
/// At startup many blocs ask for the same database at once. Without this each of them
/// would run the whole init (path lookup, exists check, two opens, version check and
/// maybe an asset copy) in parallel. A finished or failed run is forgotten, so a later
/// call (after the database was closed, or after a failure) opens it again.
class SharedOpen<T> {
  Future<T>? _pending;

  Future<T> run(Future<T> Function() open) async {
    final Future<T> running = _pending ??= open();
    try {
      return await running;
    } finally {
      if (identical(_pending, running)) _pending = null;
    }
  }
}
