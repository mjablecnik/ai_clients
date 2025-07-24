import 'package:ai_clients/ai_clients.dart';
import 'package:ai_clients/logging/logging.dart';

final _logger = Logger(
  config: LogConfig(
    enabled: true,
    globalLevel: LogLevel.debug,
    enableFileOutput: false,
    enableConsoleOutput: false,
    logFilePath: "test.log",
  ),
);

class TaskManagerAgent extends AiAgent {
  @override
  late final List<Tool> tools;

  TaskManagerAgent()
    : super(
        client: AiClients.gemini(
          logger: _logger,
        ),
        description: """
          Jsi úkolový manažer. 
          Ukládáš všechny úkoly které je potřeba splnit, kontroluješ co už bylo splněno a co ještě ne a aktulalizuješ seznam úkolů.
          Před vytvořením nového úkolu se vždy ujisti, zda daný úkol už v seznamu neexistuje.
        """,
        logger: _logger,
      );

  static Future<TaskManagerAgent> init() async {
    final agent = TaskManagerAgent();
    await agent._setupTools();
    return agent;
  }

  _setupTools() async {
    final AiMcpClient client = await AiMcpClient().sse(url: Uri.parse('http://localhost:8081/sse'));
    tools = await client.getTools();
  }
}
