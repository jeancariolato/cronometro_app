import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';


class Homepage extends StatefulWidget {
  const Homepage({super.key});

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
  Duration tempoSalvo = Duration.zero; // ⏳ Armazena o tempo antes do pause

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
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('Cronômetro', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '${duracao.inHours.toString().padLeft(2, '0')}:' 
              '${(duracao.inMinutes % 60).toString().padLeft(2, '0')}:' 
              '${(duracao.inSeconds % 60).toString().padLeft(2, '0')}',
              style: TextStyle(fontSize: 48, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, foregroundColor: Colors.black,
                    shape: CircleBorder(), padding: EdgeInsets.all(25),
                    minimumSize: Size(80, 80),
                  ),
                  onPressed: startStop,
                  child: Icon(rodando ? Icons.pause : Icons.play_arrow, size: 35),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, foregroundColor: Colors.black,
                    shape: CircleBorder(), padding: EdgeInsets.all(25),
                    minimumSize: Size(80, 80),
                  ),
                  onPressed: resetar,
                  child: Icon(Icons.refresh, size: 35),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white, foregroundColor: Colors.black,
                    shape: CircleBorder(), padding: EdgeInsets.all(25),
                    minimumSize: Size(80, 80),
                  ),
                  onPressed: adicionarVolta,
                  child: Icon(Icons.flag, size: 35),
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
                        Text('Volta ${index + 1}', style: TextStyle(color: Colors.white)),
                        Text(formatTime(voltas[index]), style: TextStyle(color: Colors.grey)),
                        Text(formatTime(temposTotais[index]), style: TextStyle(color: Colors.white70)),
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
        tempoSalvo = duracao; // Salva o tempo antes de pausar
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
