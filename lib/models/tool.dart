import 'parameter.dart';

class Tool {
  final String name;
  final String description;
  final Function function;
  List<Parameter> parameters;

  Map<String, dynamic> arguments = const {};

  Tool({
    required this.name,
    required this.description,
    required this.function,
    this.parameters = const [],
    //this.arguments = const {},
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'parameters': parameters.map((p) => p.toJson()).toList(),
  };

  Future<String> call() async {
    return await function(arguments);
  }

  @override
  String toString() =>
      'Tool(name: $name, description: $description, parameters: $parameters, arguments: $arguments)';
}