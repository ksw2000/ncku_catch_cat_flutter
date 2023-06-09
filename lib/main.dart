import 'dart:async';
import 'dart:convert';

import 'package:catch_cat/register.dart';
import 'package:catch_cat/home.dart';
import 'package:catch_cat/play.dart';
import 'package:catch_cat/setting.dart';
import 'package:catch_cat/ranking.dart';
import 'package:catch_cat/friends.dart';
import 'package:catch_cat/util.dart';
import 'package:catch_cat/album.dart';
import 'package:catch_cat/story.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:localstorage/localstorage.dart';

import 'data.dart';

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
        "/": (context) => const Middle(),
        "/register": (context) => const RegisterPage(),
        "/play": (context) => const PlayGround(),
        "/play/ranking": (context) => const RankingPage(),
        "/setting": (context) => const SettingPage(),
        "/friends": (context) => const FriendPage(),
        "/album": (context) => const AlbumPage(),
        "/story": (context) => const StoryPage(),
      },
    );
  }
}

class Middle extends ConsumerStatefulWidget {
  const Middle({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _MiddleState();
}

class _MiddleState extends ConsumerState<Middle> {
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo().then((_) {
      _updateLastLoginPeriodically();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(userDataProvider) == null) {
      return const LoginPage();
    }
    return const HomePage();
  }

  Future _fetchUserInfo() async {
    if (ref.read(userDataProvider) != null) return;
    final storage = LocalStorage('cat');
    // get from local storage
    try {
      await storage.ready;
      String? session = await storage.getItem('session');
      if (session != null) {
        // /user/me does not return session value
        // set session value at front-end service
        http.Response res = await http.post(uri(domain, '/user/me'),
            body: jsonEncode({'session': session}));
        debugPrint(res.body);
        Map<String, dynamic> j = jsonDecode(res.body);
        UserData user = UserData.fromMap(j);
        user.session = session;
        ref.read(userDataProvider.notifier).state = user;
      }
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  Future _updateLastLoginPeriodically() async {
    _timer = Timer.periodic(const Duration(seconds: 60), (timer) async {
      if (ref.read(userDataProvider) != null) {
        final res = await http.post(uri(domain, '/user/update/last_login'),
            body: jsonEncode({"session": ref.read(userDataProvider)?.session}));
        debugPrint(res.body);
      }
    });
  }
}

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _scrollCtrl.dispose();
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
          child: Scrollbar(
        controller: _scrollCtrl,
        child: SingleChildScrollView(
          controller: _scrollCtrl,
          child: Center(
              child: Container(
            constraints: const BoxConstraints(maxWidth: 500),
            padding: const EdgeInsets.symmetric(vertical: 50, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Image.asset('assets/images/logo.png', width: 120),
                const SizedBox(height: 20),
                TextField(
                  controller: _emailCtrl,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Email',
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _pwdCtrl,
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
                            _login(_emailCtrl.text, _pwdCtrl.text);
                          }
                        },
                        child: const Text('登入')),
                  ],
                ),
              ],
            ),
          )),
        ),
      )),
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

    UserData user = UserData.fromMap(j);

    // put in local storage
    final storage = LocalStorage('cat');
    await storage.ready;
    await storage.setItem('session', user.session);

    ref.read(userDataProvider.notifier).state = user;
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/');
    }
  }
}
