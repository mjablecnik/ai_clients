import 'dart:io';

import 'package:ai_clients/ai_clients.dart';

import 'task_manager_agent.dart';

Future<void> main() async {
  print('Terminálová aplikace spuštěna. Pro ukončení zadejte "exit".');
  
  bool running = true;

  final agent = await TaskManagerAgent.init();
  
  while (running) {
    stdout.write('> ');
    String? input = stdin.readLineSync();
    
    if (input == null) {
      print('Chyba při čtení vstupu.');
      continue;
    }
    
    if (input.toLowerCase() == 'exit') {
      print('Ukončuji aplikaci...');
      running = false;
      continue;
    }
    
    Message response = await agent.sendMessage(Message.user(input));
    print(response.content);
  }
}