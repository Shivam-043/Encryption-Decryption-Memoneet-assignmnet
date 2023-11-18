import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Database? _database;
  final TextEditingController _inputController = TextEditingController();
  List<String> decryptString = [];

  Future<void>? _databaseInitialization;

  @override
  void initState() {
    super.initState();
    _databaseInitialization = _initDatabase();
  }

  Future<void> _initDatabase() async {
    WidgetsFlutterBinding.ensureInitialized();
    _database = await openDatabase(
      join(await getDatabasesPath(), 'my_database.db'),
      onCreate: (db, version) {
        return db.execute(
          "CREATE TABLE my_table(id INTEGER PRIMARY KEY, encryptedText TEXT)",
        );
      },
      version: 1,
    );
  }

  BuildContext? tempContext;

  Future<void> _encryptAndSave(BuildContext context) async {
    String inputText = _inputController.text;
    tempContext = context;
    var temp = await _database?.rawQuery("select * from my_table");
    print(temp);
    if (inputText.isNotEmpty) {
      // Encrypt the string
      String encryptedText = _encryptString(inputText);

      print(encryptedText);

      // Save the encrypted string to the database
      await _database
          ?.insert('my_table', {'encryptedText': encryptedText}).then(
              (value) => _showSnackbar("String Encrypted Successfully!")).catchError((e)=>{_showSnackbar("Error: $e")});
    }
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(tempContext!).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2), // Adjust the duration as needed
      ),
    );
  }

  Future<void> _decryptAndDisplay() async {
    // Retrieve the encrypted string from the database
    List<Map<String, dynamic>> rows =
        await _database!.rawQuery("SELECT * from my_table");
    // print(rows);
    if (rows.isNotEmpty) {
      setState(() {
        decryptString = rows
            .map((element) => _decryptString(element['encryptedText']))
            .toList();
      });
    }
  }

  String _encryptString(String input) {
    List<int> bytes = utf8.encode(input);
    String encrypted = base64.encode(bytes);
    return encrypted;
  }

  String _decryptString(String encrypted) {
    Uint8List bytes = base64.decode(encrypted);
    String decrypted = utf8.decode(bytes);
    return decrypted;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Encryption & Decryption App')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _inputController,
                decoration: InputDecoration(labelText: 'Enter String to Encrypt'),
              ),
              SizedBox(height: 16),
              FilledButton(
                style : ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.green)),
                onPressed: () async {
                  await _encryptAndSave(context);
                },
                child: Text('Encrypt and Save'),
              ),
              SizedBox(height: 16),
              FilledButton(
                style: ButtonStyle(backgroundColor: MaterialStateColor.resolveWith((states) => Colors.green)),
                onPressed: () async {
                  await _decryptAndDisplay();
                },
                child: Text('Decrypt and Display'),
              ),
              SizedBox(height: 16),
              Text("String After Decryption :- " , style: TextStyle(fontSize: 20 , ),),
              SizedBox(height: 16),
              Container(
                height: 500,
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.all(Radius.circular(10))),
                child: Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: (decryptString.isNotEmpty)
                          ? decryptString
                              .map((decrypted) => ListTile(
                                    title: Text(decrypted),
                                  ))
                              .toList()
                          : [Container()],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
