import 'package:ai_clients/src/models.dart';

class Utils {
  static String buildPrompt({required String prompt, List<Context>? contexts}) {
    final sb = StringBuffer(prompt);
    if (contexts != null && contexts.isNotEmpty) {
      for (final context in contexts) {
        sb.writeln('');
        sb.writeln('===========${context.name == null ? '' : '${context.name!.toUpperCase()} '} CONTEXT===========');
        sb.write(context.value);
        sb.writeln('=============================');
      }
    }
    return sb.toString();
  }
}
