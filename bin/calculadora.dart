import 'dart:io';

void main() {
  print("=== Calculadora CLI em Dart ===");
  print("Digite sua expressão ou 'sair':");

  while (true) {
    stdout.write("\n> ");
    String? input = stdin.readLineSync()?.replaceAll(' ', '');

    if (input == null) break;
    if (input.isEmpty) continue;

    try {
      double resultado = calcular(input);
      print("Resultado: ${resultado % 1 == 0 ? resultado.toInt() : resultado}");
    } catch (e) {
      print("Erro: $e");
    }
  }
}

double calcular(String expressao) {
  if (RegExp(r'[\+\-\*/]$').hasMatch(expressao)) {
    throw "Expressão incompleta! Está faltando um número após o operador.";
  }
  if (RegExp(r'[\+\-\*/]{2,}').hasMatch(expressao)) {
    throw "Operadores duplicados detectados.";
  }
  if ('('.allMatches(expressao).length != ')'.allMatches(expressao).length) {
    throw "Parênteses não fechados.";
  }
  if('('.allMatches(expressao).length < 2){
    throw "Digite mais de um valor";
  }

  final tokens = RegExp(r'(\d+\.?\d*)|([\+\-\*\/\(\)])')
      .allMatches(expressao)
      .map((m) => m.group(0)!)
      .toList();

  return _avaliar(tokens);
}

double _avaliar(List<String> tokens) {
  List<double> valores = [];
  List<String> operadores = [];

  int precedencia(String op) {
    if (op == '+' || op == '-') return 1;
    if (op == '*' || op == '/') return 2;
    return 0;
  }

  void aplicarOperador() {
    if (valores.length < 2) throw "Erro de sintaxe";
    double b = valores.removeLast();
    double a = valores.removeLast();
    String op = operadores.removeLast();

    switch (op) {
      case '+': valores.add(a + b); break;
      case '-': valores.add(a - b); break;
      case '*': valores.add(a * b); break;
      case '/': 
        if (b == 0) throw "Divisão por zero!";
        valores.add(a / b); 
        break;
    }
  }

  for (var i = 0; i < tokens.length; i++) {
    String t = tokens[i];

    if (double.tryParse(t) != null) {
      valores.add(double.parse(t));
    } else if (t == '(') {
      operadores.add(t);
    } else if (t == ')') {
      while (operadores.isNotEmpty && operadores.last != '(') {
        aplicarOperador();
      }
      operadores.removeLast(); 
    } else {
      while (operadores.isNotEmpty && 
             precedencia(operadores.last) >= precedencia(t)) {
        aplicarOperador();
      }
      operadores.add(t);
    }
  }

  while (operadores.isNotEmpty) {
    aplicarOperador();
  }

  return valores.first;
}