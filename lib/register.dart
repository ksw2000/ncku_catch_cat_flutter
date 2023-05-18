import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});
  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final scrollCtrl = ScrollController();
  final emailCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final pwdCtrl = TextEditingController();
  final confirmPwdCtrl = TextEditingController();

  @override
  void dispose() {
    emailCtrl.dispose();
    nameCtrl.dispose();
    pwdCtrl.dispose();
    confirmPwdCtrl.dispose();
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('註冊'),
        ),
        body: SafeArea(
            child: Scrollbar(
                controller: scrollCtrl,
                child: SingleChildScrollView(
                    controller: scrollCtrl,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Column(children: [
                        TextField(
                          controller: emailCtrl,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'Email',
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextField(
                          controller: nameCtrl,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '暱稱',
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
                        TextField(
                          controller: confirmPwdCtrl,
                          obscureText: true,
                          enableSuggestions: false,
                          autocorrect: false,
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: '確認密碼',
                          ),
                        ),
                        const SizedBox(height: 20),
                        OutlinedButton(
                            onPressed: _reg, child: const Text('送出')),
                      ]),
                    )))));
  }

  void _reg() {
    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
      content: Text('註冊成功'),
    ));
  }
}
