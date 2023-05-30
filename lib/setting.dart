import 'dart:convert';

import 'package:catch_cat/data.dart';
import 'package:catch_cat/util.dart';
import 'package:catch_cat/profile.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _oriPwdCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _oriPwdCtrl.dispose();
    _newPwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(userDataProvider) == null) {
      return const SizedBox();
    }

    const titleTextStyle = TextStyle(fontSize: 20);
    const separator = SizedBox(
      height: 20,
    );

    // set initialize value
    _nameCtrl.text = ref.read(userDataProvider)!.name;
    _emailCtrl.text = ref.read(userDataProvider)!.email;

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('設定'),
        ),
        body: SafeArea(
            child: Scrollbar(
                controller: _scrollCtrl,
                child: SingleChildScrollView(
                    controller: _scrollCtrl,
                    child: Center(
                      child: Container(
                          constraints: const BoxConstraints(maxWidth: 500),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 20),
                          child: Center(
                              child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Center(child: ProfilePhoto(size: 100)),
                              separator,
                              const Text(
                                '修改暱稱',
                                style: titleTextStyle,
                              ),
                              separator,
                              TextField(
                                controller: _nameCtrl,
                                enableSuggestions: false,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: '暱稱',
                                ),
                              ),
                              separator,
                              OutlinedButton(
                                  onPressed: _updateName,
                                  child: const Text('修改')),
                              separator,
                              const Text('修改 Email', style: titleTextStyle),
                              separator,
                              TextField(
                                controller: _emailCtrl,
                                obscureText: false,
                                enableSuggestions: false,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: 'Email',
                                ),
                              ),
                              separator,
                              OutlinedButton(
                                  onPressed: _updateEmail,
                                  child: const Text('修改')),
                              separator,
                              const Text(
                                '修改密碼',
                                style: titleTextStyle,
                              ),
                              separator,
                              TextField(
                                controller: _oriPwdCtrl,
                                obscureText: true,
                                enableSuggestions: false,
                                autocorrect: false,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: '原始密碼',
                                ),
                              ),
                              separator,
                              TextField(
                                controller: _newPwdCtrl,
                                obscureText: true,
                                enableSuggestions: false,
                                autocorrect: false,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: '新密碼',
                                ),
                              ),
                              separator,
                              TextField(
                                controller: _confirmPwdCtrl,
                                obscureText: true,
                                enableSuggestions: false,
                                autocorrect: false,
                                decoration: const InputDecoration(
                                  border: OutlineInputBorder(),
                                  hintText: '確認密碼',
                                ),
                              ),
                              separator,
                              OutlinedButton(
                                  onPressed: _updatePassword,
                                  child: const Text('修改')),
                            ],
                          ))),
                    )))));
  }

  Future _updateName() async {
    http.Response res = await http.post(uri(domain, '/user/update/name'),
        body: jsonEncode({
          "session": ref.read(userDataProvider)?.session ?? "",
          "name": _nameCtrl.text
        }));
    debugPrint(res.body);
    Map<String, dynamic> j = jsonDecode(res.body);
    if (context.mounted && j['error'] != "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(j['error']),
      ));
      return;
    }
    if (context.mounted && res.statusCode == 201) {
      final user = ref.read(userDataProvider)!.copy();
      user.name = _nameCtrl.text;
      ref.read(userDataProvider.notifier).state = user;

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("修改成功"),
      ));
      return;
    }
  }

  Future _updatePassword() async {
    http.Response res = await http.post(uri(domain, '/user/update/password'),
        body: jsonEncode({
          "session": ref.read(userDataProvider)?.session ?? "",
          "original_password": _oriPwdCtrl.text,
          "new_password": _newPwdCtrl.text,
          "confirm_password": _confirmPwdCtrl.text
        }));
    debugPrint(res.body);
    Map<String, dynamic> j = jsonDecode(res.body);
    if (context.mounted && j['error'] != "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(j['error']),
      ));
      return;
    }
    if (context.mounted && res.statusCode == 201) {
      _oriPwdCtrl.clear();
      _newPwdCtrl.clear();
      _confirmPwdCtrl.clear();

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("修改成功"),
      ));
      return;
    }
  }

  Future _updateEmail() async {
    http.Response res = await http.post(uri(domain, '/user/update/email'),
        body: jsonEncode({
          "session": ref.read(userDataProvider)?.session ?? "",
          "email": _emailCtrl.text,
        }));
    debugPrint(res.body);
    Map<String, dynamic> j = jsonDecode(res.body);
    if (context.mounted && j['error'] != "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(j['error']),
      ));
      return;
    }
    if (context.mounted && res.statusCode == 201) {
      final user = ref.read(userDataProvider)!.copy();
      user.email = _emailCtrl.text;
      ref.read(userDataProvider.notifier).state = user;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text("修改成功"),
      ));
      return;
    }
  }
}
