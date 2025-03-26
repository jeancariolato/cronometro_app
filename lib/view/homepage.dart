import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

class Homepage extends StatefulWidget {
  final Function(bool) onThemeChanged; // Callback para alternar tema
  const Homepage({super.key, required this.onThemeChanged});

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  Duration duracao = Duration.zero;
  Timer? cronometro;
  bool rodando = false;
  List<Duration> voltas = [];
  List<Duration> temposTotais = [];
  DateTime? _startTime;
  Duration tempoSalvo = Duration.zero;

  @override
  void dispose() {
    cronometro?.cancel();
    FlutterForegroundTask.stopService();
    super.dispose();
  }

  String formatTime(Duration duration) {
    return '${duration.inMinutes.toString().padLeft(2, '0')}:'
           '${(duration.inSeconds % 60).toString().padLeft(2, '0')}.'
           '${(duration.inMilliseconds % 1000 ~/ 10).toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Text('Cronômetro', style: TextStyle(color: Theme.of(context).appBarTheme.titleTextStyle!.color)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              isDarkMode ? Icons.light_mode : Icons.dark_mode,
              color: Theme.of(context).appBarTheme.titleTextStyle!.color,
            ),
            onPressed: () {
              widget.onThemeChanged(!isDarkMode); // Alterna o tema
            },
            tooltip: isDarkMode ? 'Mudar para modo claro' : 'Mudar para modo escuro',
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Semantics(
              label: "Tempo decorrido: ${formatTime(duracao)}",
              child: Text(
                '${duracao.inHours.toString().padLeft(2, '0')}:'
                '${(duracao.inMinutes % 60).toString().padLeft(2, '0')}:'
                '${(duracao.inSeconds % 60).toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: 48,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyMedium!.color,
                ),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Tooltip(
                  message: rodando ? "Pausar cronômetro" : "Iniciar cronômetro",
                  child: Semantics(
                    label: rodando ? "Botão para pausar o cronômetro" : "Botão para iniciar o cronômetro",
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(25),
                        minimumSize: Size(80, 80),
                      ),
                      onPressed: startStop,
                      child: Icon(rodando ? Icons.pause : Icons.play_arrow, size: 35),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Tooltip(
                  message: "Reiniciar cronômetro",
                  child: Semantics(
                    label: "Botão para reiniciar o cronômetro",
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(25),
                        minimumSize: Size(80, 80),
                      ),
                      onPressed: resetar,
                      child: Icon(Icons.refresh, size: 35),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Tooltip(
                  message: "Adicionar volta",
                  child: Semantics(
                    label: "Botão para adicionar uma volta",
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: CircleBorder(),
                        padding: EdgeInsets.all(25),
                        minimumSize: Size(80, 80),
                      ),
                      onPressed: adicionarVolta,
                      child: Icon(Icons.flag, size: 35),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: voltas.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: EdgeInsets.symmetric(horizontal: 20),
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Volta ${index + 1}',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium!.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatTime(voltas[index]),
                          style: TextStyle(
                            color: isDarkMode ? Colors.white : Colors.black, // Branco no dark mode, preto no light mode
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          formatTime(temposTotais[index]),
                          style: TextStyle(
                            color: Theme.of(context).textTheme.titleMedium!.color,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void startForegroundService() async {
    await FlutterForegroundTask.startService(
      notificationTitle: "Cronômetro Rodando",
      notificationText: "Seu cronômetro continua em segundo plano",
      callback: () {
        print("Executando cronômetro...");
      },
    );
  }

  void startStop() async {
    if (rodando) {
      cronometro?.cancel();
      await FlutterForegroundTask.stopService();
      setState(() {
        tempoSalvo = duracao;
        rodando = false;
      });
    } else {
      _startTime = DateTime.now();
      cronometro = Timer.periodic(Duration(milliseconds: 10), (_) async {
        final now = DateTime.now();
        setState(() {
          duracao = tempoSalvo + now.difference(_startTime!);
        });
      });
      startForegroundService();
      setState(() {
        rodando = true;
      });
    }
  }

  void resetar() {
    cronometro?.cancel();
    FlutterForegroundTask.stopService();
    setState(() {
      duracao = Duration.zero;
      tempoSalvo = Duration.zero;
      rodando = false;
      voltas.clear();
      temposTotais.clear();
      _startTime = null;
    });
  }

  void adicionarVolta() {
    if (rodando) {
      setState(() {
        final voltaAtual = voltas.isEmpty ? duracao : duracao - temposTotais.last;
        voltas.add(voltaAtual);
        temposTotais.add(duracao);
      });
    }
  }
}