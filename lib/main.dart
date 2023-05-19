import 'package:catch_cat/register.dart';
import 'package:catch_cat/select.dart';
import 'package:catch_cat/play.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '尋找貓貓',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      routes: {
        "/": (context) => const MyHomePage(title: '登入'),
        "/select": (context) => const SelectPage(),
        "/register": (context) => const RegisterPage(),
        "/play": (context) => const PlayGround(),
      },
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
  final pwdCtrl = TextEditingController();
  final actCtrl = TextEditingController();

  @override
  void dispose() {
    pwdCtrl.dispose();
    actCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: SafeArea(
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Image.asset('assets/images/logo.png', width: 120),
                    const SizedBox(height: 20),
                    TextField(
                      controller: actCtrl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '帳號',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextField(
                      controller: pwdCtrl,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: '密碼',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        OutlinedButton(
                            onPressed: () {
                              Navigator.pushNamed(context, '/register');
                            },
                            child: const Text('註冊')),
                        const SizedBox(width: 20),
                        OutlinedButton(
                            onPressed: () {
                              String pwd = pwdCtrl.text;
                              String act = actCtrl.text;
                              _login(pwd, act);
                            },
                            child: const Text('登入')),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/select');
                        },
                        child: const Text('訪客登入'))
                  ],
                ),
              ))),
    );
  }

  void _login(String pwd, String act) {
    if (act == 'admin' && pwd == '00000000') {
      Navigator.pushNamed(context, '/select');
      // Navigator.push(
      //     context, MaterialPageRoute(builder: (context) => const SelectPage()));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('帳號或密碼錯誤'),
      ));
    }
  }
}
