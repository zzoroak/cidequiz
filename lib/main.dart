import 'dart:math';

import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '농약 Quiz',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: '농약 퀴즈'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isLoading = true;
  List<List<dynamic>> _data = [];
  int _randomNumber = 0;

  int totalCounter = 0;
  int rightCounter = 0;

  String _currentText = "";
  String _currentAnswer = "";
  bool _isShowAnswer = true;
  bool _isRight = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final rawData = await rootBundle.loadString('data/data.csv');
    List<List<dynamic>> csvData =
        const CsvToListConverter(eol: '\n').convert(rawData);

    setState(() {
      _data = csvData;
      _isLoading = false;
      _showNextRandom();
    });
  }

  void _showNextRandom() {
    if (_data.isNotEmpty) {
      setState(() {
        _randomNumber = Random().nextInt(_data.length);
        _currentText = _data[_randomNumber][0].toString();
        _currentAnswer = _data[_randomNumber][1].toString();
        _isRight = false; // 새로운 질문 시 정답 여부 초기화
      });
    }
  }

  void changeButton(String answer) {
    setState(() {
      if (_isShowAnswer) {
        _isRight = identical(_currentAnswer.substring(0,2), answer);
        totalCounter++;
        if (_isRight) rightCounter++;
        _isShowAnswer = false; // 정답 보여주기
      } else {
        _showNextRandom();
        _isShowAnswer = true; // 다시 정답 보기로 변경
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          centerTitle: true,
          title: Text("정답: " +
              rightCounter.toString() +
              " / " +
              totalCounter.toString())),
      body: Center(
        child: _isLoading
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    _data.isNotEmpty ? _currentText : '데이터가 없습니다.',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 20),
                  Text(_isShowAnswer
                      ? " "
                      : _isRight
                          ? "⭕"
                          : "❌"),
                  const SizedBox(height: 5),
                  Text(
                    _data.isNotEmpty
                        ? _isShowAnswer
                            ? " "
                            : _isRight
                                ? _currentAnswer
                                : _currentAnswer
                        : " ",
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 20),
                  _isShowAnswer
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            FilledButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.lightGreen),
                              ),
                              onPressed: () => changeButton("살충"),
                              child: const Text("살충제"),
                            ),
                            const SizedBox(width: 5),
                            FilledButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.amber),
                              ),
                              onPressed: () => changeButton("제초"),
                              child: const Text("제초제"),
                            ),
                            const SizedBox(width: 5),
                            FilledButton(
                              style: ButtonStyle(
                                backgroundColor:
                                    WidgetStateProperty.all(Colors.pink),
                              ),
                              onPressed: () => changeButton("살균"),
                              child: const Text("살균제"),
                            ),
                          ],
                        )
                      : FilledButton(
                          onPressed: () => changeButton(""),
                          child: const Text("다음"),
                        ),
                ],
              ),
      ),
    );
  }
}
