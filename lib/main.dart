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
  String _currentText = "";
  String _currentAnswer = "";
  bool _isShowAnswer = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  void loadData() async {
    final rawData = await rootBundle.loadString('data/data.csv');
    List<List<dynamic>> csvData = const CsvToListConverter(eol: '\n').convert(rawData);

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
      });
    }
  }

  void changeButton() {
    setState(() {
      if (_isShowAnswer) {
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
                  const SizedBox(height: 10),
                  Text(
                      _data.isNotEmpty
                          ? _isShowAnswer
                              ? " "
                              : _currentAnswer
                          : " ",
                      style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: changeButton,
                    child: Text(_isShowAnswer ? "정답 보기" : "다음"),
                  ),
                ],
              ),
      ),
    );
  }
}
