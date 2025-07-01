class Parameter {
  final String name;
  final String type;
  final String description;
  final bool required;
  final List<String>? enumValues;

  const Parameter({
    required this.name,
    required this.type,
    required this.description,
    this.required = false,
    this.enumValues,
  });

  factory Parameter.fromJson(Map<String, dynamic> json) {
    return Parameter(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      description: json['description'] ?? '',
      required: json['required'] ?? false,
      enumValues: (json['enum'] as List?)?.map((e) => e.toString()).toList(),
    );
  }

  Map<String, dynamic> toJson() {
    final map = {
      'name': name,
      'type': type,
      'description': description,
      'required': required,
    };
    if (enumValues != null) {
      map['enum'] = enumValues!;
    }
    return map;
  }

  @override
  String toString() =>
      'Parameter(name: \$name, type: \$type, description: \$description, required: \$required, enumValues: \$enumValues)';
}