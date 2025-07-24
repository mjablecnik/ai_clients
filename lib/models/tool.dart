import 'parameter.dart';

class Tool {
  final String name;
  final String description;
  final Future<String> Function(Map<String, dynamic>) function;
  List<Parameter> parameters;

  Tool({
    required this.name,
    required this.description,
    required this.function,
    this.parameters = const [],
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'parameters': parameters.map((p) => p.toJson()).toList(),
  };

  Future<String> call(Map<String, dynamic> arguments) async {
    return await function(arguments);
  }

  @override
  String toString() =>
      'Tool(name: $name, description: $description, parameters: $parameters)';
}