import 'package:ai_clients/models/context.dart';

String buildPrompt({required String prompt, List<Context>? contexts}) {
  final sb = StringBuffer(prompt);
  if (contexts != null && contexts.isNotEmpty) {
    for (final context in contexts) {
      sb.writeln('\n');
      sb.writeln('=========== ${context.name == null ? '' : context.name!.toUpperCase()} CONTEXT ===========');
      sb.writeln(context.value);
      sb.writeln('=============================');
    }
  }
  return sb.toString();
}