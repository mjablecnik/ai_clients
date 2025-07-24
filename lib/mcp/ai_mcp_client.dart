import 'package:ai_clients/models/parameter.dart';
import 'package:ai_clients/models/tool.dart';
import 'package:mcp_client/mcp_client.dart' hide Tool;

class AiMcpClient {
  final String name;
  final String version;
  final bool enableDebugLogging;

  Client? client;

  AiMcpClient({this.name = 'Example Client', this.version = '1.0.0', this.enableDebugLogging = true});

  Future<dynamic> sse({required Uri url}) async {
    final config = McpClient.simpleConfig(name: name, version: version, enableDebugLogging: enableDebugLogging);

    final transportConfig = TransportConfig.sse(
      serverUrl: url.toString(),
      headers: {'User-Agent': 'MCP-Client/1.0'},
    );

    final clientResult = await McpClient.createAndConnect(config: config, transportConfig: transportConfig);

    client = clientResult.fold((c) => c, (error) => throw Exception('Failed to connect: $error'));
    return this;
  }

  Future<List<Tool>> getTools() async {
    if (client == null) throw Exception('Client is not initialized');

    final listTools = await client!.listTools();
    final List<Tool> tools = [];

    for (final tool in listTools) {
      final List<Parameter> parameters = [];

      if (tool.inputSchema['type'] == 'object') {
        final properties = tool.inputSchema['properties'];
        for (final property in properties.entries) {
          parameters.add(
            Parameter(
              name: property.key,
              type: property.value['type'],
              description: property.value['description'],
              required: (tool.inputSchema['required'] as List).contains(property.key),
              enumValues: property.value['enum'],
            ),
          );
        }
      }

      tools.add(
        Tool(
          name: tool.name,
          description: tool.description,
          parameters: parameters,
          function: (Map<String, dynamic> arguments) async {
            final result = await client!.callTool(tool.name, arguments);
            return (result.content.first as TextContent).text;
          },
        ),
      );
    }

    return tools;
  }
}
