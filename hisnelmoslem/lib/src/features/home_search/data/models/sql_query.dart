class SqlQuery {
  String query;
  List<Object?> args;

  SqlQuery({this.query = "", List<Object?>? args})
      : args = args ?? List.empty(growable: true);

  @override
  String toString() {
    return 'SqlQuery{query: $query, args: $args}';
  }
}
