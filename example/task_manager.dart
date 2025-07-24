import 'package:ai_clients/ai_clients.dart';

void main() async {
  final AiMcpClient client = await AiMcpClient().sse(url: Uri.parse('http://localhost:8081/sse'));
  final allTools = await client.getTools();

  //var aiClient = AiClients.together(model: 'meta-llama/Llama-3.3-70B-Instruct-Turbo');
  //var aiClient = AiClients.openAi(model: 'gpt-4o-mini');
  //var aiClient = AiClients.baseten();
  var aiClient = AiClients.gemini();
  var aiAgent = AiAgent(
    client: aiClient,
    description:
        "Jsi úkolový manažer. Ukládáš všechny úkoly které je potřeba splnit, kontroluješ co už bylo splněno a co ještě ne a aktulalizuješ seznam úkolů."
        "Před vytvořením nového úkolu se vždy ujisti, zda daný úkol už v seznamu neexistuje.",
    tools: allTools,
  );

  try {
    var response = await aiAgent.sendMessage(
      Message.user("Ulož do seznamu následující úkoly: Vyprat prádlo, vyžehlit, dojít na nákup"),
    );

    print(response.content);
    print('\n');

    response = await aiAgent.sendMessage(Message.user("řekni mi, jaké úkoly je dnes potřeba splnit"));

    print(response.content);
    print('\n');

  } catch (e) {
    print(e);
  }

  //aiAgent.showHistory();
}
