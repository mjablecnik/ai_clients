class Context {
  final String? name;
  final String value;

  const Context({this.name, required this.value});

  @override
  String toString() => 'Context(name: \$name, value: \$value)';
}