import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:lab6/quote.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            backgroundColor: Colors.blueGrey,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
          ),
        ),
      ),
      home: const MyHomePage(title: 'HTTP + DIO'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;

  late Quote quote;

  String text = 'Получи данные';

  final Dio _dio = Dio();

  @override
  void initState() {
    super.initState();

    // Опции Dio
    _dio.options.baseUrl = 'https://dummyjson.com';
    _dio.options.connectTimeout = const Duration(seconds: 5);
    _dio.options.receiveTimeout = const Duration(seconds: 3);

    getDataHttp();
  }

  getDataHttp() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Запрос
      final response = await http
          .get(Uri.parse('https://dummyjson.com/quotes/random'))
          .timeout(const Duration(seconds: 5));

      if (kDebugMode) {
        print(response.body);
      }

      // Если запрос выполнен успешно
      if (response.statusCode == 200) {
        var data = json.decode(response.body);
        quote = Quote.fromJson(data as Map<String, dynamic>);

        // Отобразим цитату
        setState(() {
          text = '${quote.quote}\n - ${quote.author}';
          isLoading = false;
        });
      }
    } on TimeoutException {
      setState(() {
        text = 'HTTP Timeout';
        isLoading = false;
      });
    } catch (ex) {
      setState(() {
        text = 'HTTP Exception';
        isLoading = false;
      });
    }
  }

  getDataDio() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Запрос
      final response = await _dio.get('/quotes/random');
      if (kDebugMode) {
        print(response.data);
      }

      // Если запрос выполнен успешно
      if (response.statusCode == 200) {
        quote = Quote.fromJson(response.data as Map<String, dynamic>);

        // Отобразим цитату
        setState(() {
          text = '${quote.quote}\n - ${quote.author}';
          isLoading = false;
        });
      }
    } on DioException catch (ex) {
      if (kDebugMode) {
        print(ex.response);
      }
      setState(() {
        if (ex.type == DioExceptionType.connectionTimeout ||
            ex.type == DioExceptionType.receiveTimeout) {
          text = 'DIO Timeout';
        } else {
          text = 'DIO Exception';
        }
        isLoading = false;
      });
    }
  }

  getError() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Запрос
      final response = await _dio.get('/http/404/Not_found!');
    } on DioException catch (ex) {
      if (kDebugMode) {
        print(ex.message);
      }
      setState(() {
        text = ex.message.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        //backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        backgroundColor: Colors.blueGrey,
        foregroundColor: Colors.white,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
        centerTitle: true,
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          //
          // TRY THIS: Invoke "debug painting" (choose the "Toggle Debug Paint"
          // action in the IDE, or press "p" in the console), to see the
          // wireframe for each widget.
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
                padding: const EdgeInsets.all(16.0),
                child: isLoading
                    ? const CircularProgressIndicator(color: Colors.blueGrey)
                    : Text(text)),
            TextButton(
                onPressed: isLoading ? () {} : getDataHttp,
                child: const Text('HTTP')),
            TextButton(
                onPressed: isLoading ? () {} : getDataDio,
                child: const Text('DIO')),
            TextButton(
                onPressed: isLoading ? () {} : getError,
                child: const Text('ERROR')),
          ],
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
