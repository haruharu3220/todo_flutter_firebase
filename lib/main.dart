// import 'dart:html';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

// void main() {
//   runApp(const MyApp());
// }

//非同期通信
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.cuurentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

const collectionKey = 'hayaharu_todo';

class _MyHomePageState extends State<MyHomePage> {
  List<Item> items = [];
  final TextEditingController textEditingController = TextEditingController();
  late FirebaseFirestore firestore;

  @override
  void initState() {
    super.initState();
    firestore = FirebaseFirestore.instance;
    watch();
  }

  //データ更新監視
  Future<void> watch() async {
    firestore.collection(collectionKey).snapshots().listen((event) {
      setState(() {
        items = event.docs.reversed.map((document) =>
            Item.fromSnapshot(
              document.id,
              document.data(),
            ),).toList(growable: false);
      });
    });
  }

  //保存する
  Future<void> save() async {
    final collection = firebase.collection(collectionKey);
    final now = DateTime.now();
    await collection.doc(now.millisecondsSinceEpoch.toString()).set({
      "data" : now,
      "text" : textEditingController.text,
    });
    textEditingController.text = "";
  }

  //完了・未完了に変更する
  Future<void> complete(Item item) async {}

  //削除する
  Future<void> delete(String id) async {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Todo list'),
      ),
      body: ListView.builder(
        itemBuilder: (context, index) {
          if (index == 0) {
            return ListTile(
              title: TextField(
                controller: textEditingController,
              ),
              trailing: ElevatedButton(
                onPressed: () {
                  save();
                },
                child: Text('保存'),
              ),
            );
          }
          final item = items[index - 1];
          return ListTile(
            title: Text(item.text),
          );
        },
        itemCount: items.length + 1,
      ),
    );
  }
}

class Item {
  const Item({
    required this.id,
    required this.text,
  });

  final String id;
  final String text;

  factory Item.fromSnapshot(String id, Map<String, dynamic> document) {
    return Item(
      id: id,
      text: document['text'].toString() ?? '',
    );
  }
}
