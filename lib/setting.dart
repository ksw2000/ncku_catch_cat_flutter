import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catch_cat/data.dart';

class SettingPage extends ConsumerStatefulWidget {
  const SettingPage({super.key});

  @override
  ConsumerState<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends ConsumerState<SettingPage> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _pwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _pwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(userDataProvider) == null) {
      return const SizedBox();
    }

    final String name = ref.watch(userDataProvider)!.name;
    final String? profile = ref.watch(userDataProvider)!.profile;
    final String email = ref.watch(userDataProvider)!.email;
    const titleTextStyle = TextStyle(fontSize: 20);
    const separator = SizedBox(
      height: 20,
    );

    // set initialize value
    _nameCtrl.text = name;
    _emailCtrl.text = email;

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
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 20),
                        child: Center(
                            child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(
                              child: SizedBox(
                                height: 100,
                                width: 100,
                                child: Ink(
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: profile != null
                                          ? Image.network(
                                              profile,
                                              width: 100,
                                              scale: 1,
                                            ).image
                                          : Image.asset(
                                              defaultProfile,
                                              width: 100,
                                              scale: 1,
                                            ).image,
                                      fit: BoxFit.cover,
                                    ),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10)),
                                  ),
                                  child: InkWell(
                                    onTap: () {
                                      //TODO
                                    },
                                    splashColor: Colors.white.withOpacity(0.3),
                                  ),
                                ),
                              ),
                            ),
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
                                onPressed: () {}, child: const Text('修改')),
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
                                onPressed: () {}, child: const Text('修改')),
                            separator,
                            const Text(
                              '修改密碼',
                              style: titleTextStyle,
                            ),
                            separator,
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
                                onPressed: () {}, child: const Text('修改')),
                          ],
                        )))))));
  }
}
