import 'dart:convert';

import 'package:catch_cat/register.dart';
import 'package:catch_cat/select.dart';
import 'package:catch_cat/play.dart';
import 'package:catch_cat/setting.dart';
import 'package:catch_cat/ranking.dart';
import 'package:catch_cat/friends.dart';
import 'package:catch_cat/api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

import 'data.dart';

void main() {
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    fetchUserInfoFromLocalStorage(ref);
    return MaterialApp(
      title: '尋找貓貓',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.brown),
        useMaterial3: true,
      ),
      routes: {
        "/": (context) => const MyHomePage(),
        "/select": (context) => const SelectPage(),
        "/register": (context) => const RegisterPage(),
        "/play": (context) => const PlayGround(),
        "/play/ranking": (context) => const RankingPage(),
        "/setting": (context) => const SettingPage(),
        "/friends": (context) => const FriendPage(),
      },
    );
  }

  Future fetchUserInfoFromLocalStorage(WidgetRef ref) async {
    final storage = LocalStorage('cat');
    // get from local storage
    try {
      String? data = await storage.getItem('user');
      if (data != null) {
        Map<String, dynamic> j = jsonDecode(data);
        UserData user = UserData.fromMap(j);
        ref.read(userDataProvider.notifier).state = user;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}

class MyHomePage extends ConsumerStatefulWidget {
  const MyHomePage({super.key});

  @override
  ConsumerState<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends ConsumerState<MyHomePage> {
  final emailCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    pwdCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('登入'),
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
                      controller: emailCtrl,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Email',
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
                              if (mounted) {
                                _login(emailCtrl.text, pwdCtrl.text);
                              }
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

  void _login(String email, String pwd) async {
    http.Response res = await http.post(uri(domain, '/login'),
        body: jsonEncode({
          'password': pwd,
          'email': email,
        }));
    if (res.statusCode != 200) {
      throw (res.statusCode);
    }

    debugPrint(res.body);

    Map<String, dynamic> j = jsonDecode(res.body);
    if (mounted && j['error'] != "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(j['error']),
      ));
      return;
    }

    final storage = LocalStorage('cat');
    // put in local storage
    storage.setItem('user', res.body);

    UserData user = UserData.fromMap(j);

    ref.read(userDataProvider.notifier).state = user;
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/select');
    }
  }
}
