import 'dart:convert';

import 'package:catch_cat/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:catch_cat/util.dart';
import 'package:http/http.dart' as http;

class SelectPage extends ConsumerStatefulWidget {
  const SelectPage({super.key});
  @override
  ConsumerState<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends ConsumerState<SelectPage> {
  final scrollCtrl = ScrollController();
  @override
  void dispose() {
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: const MyDrawer(),
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SafeArea(
            child: Scrollbar(
                controller: scrollCtrl,
                child: SingleChildScrollView(
                  controller: scrollCtrl,
                  child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10.0, horizontal: 20.0),
                      child: Column(
                        children: [
                          const UserField(),
                          FutureBuilder<List<PlayThemeData>>(
                            future: _getPlayThemeList(),
                            builder: (BuildContext context,
                                AsyncSnapshot<List<PlayThemeData>> snapshot) {
                              List<Widget> children;
                              if (snapshot.hasData) {
                                children = snapshot.data!
                                    .map((e) => PlayCard(data: e))
                                    .toList();
                              } else if (snapshot.hasError) {
                                children = <Widget>[
                                  const Icon(
                                    Icons.error_outline,
                                    color: Colors.red,
                                    size: 60,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 16),
                                    child: Text('Error: ${snapshot.error}'),
                                  ),
                                ];
                              } else {
                                children = const <Widget>[
                                  SizedBox(
                                    width: 60,
                                    height: 60,
                                    child: CircularProgressIndicator(),
                                  ),
                                ];
                              }
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: children,
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Text('(๑•̀ω•́)ノ已經到底了，努力製作中',
                              style:
                                  TextStyle(fontSize: 14, color: Colors.grey))
                        ],
                      )),
                ))));
  }

  Future<List<PlayThemeData>> _getPlayThemeList() async {
    http.Response res = await http.get(
      uri(domain, '/theme_list'),
    );
    debugPrint(res.body);
    if (res.statusCode != 200) return [];
    // decode
    Map<String, dynamic> j = jsonDecode(res.body);

    // check if any error
    if (mounted && j['error'] != "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(j['error']),
      ));
    }

    return (j['list'] as List).map((e) => PlayThemeData.fromMap(e)).toList();
  }
}

class PlayCard extends ConsumerWidget {
  const PlayCard({super.key, required this.data});
  final PlayThemeData data;
//   @override
//   State<PlayCard> createState() => _PlayCardState();
// }

// class _PlayCardState extends State<PlayCard> {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        SizedBox(
            height: 200,
            child: Ink(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset(
                    data.thumbnail,
                  ).image,
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
              child: InkWell(
                onTap: () {
                  ref.read(playDataProvider.notifier).state = data;
                  Navigator.pushNamed(context, '/play');
                },
                splashColor: Colors.white.withOpacity(0.3),
              ),
            )),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child: Text(data.name, style: const TextStyle(fontSize: 18))),
      ]),
    );
  }
}

class MyDrawer extends ConsumerWidget {
  const MyDrawer({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserData? user = ref.watch(userDataProvider);
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          SizedBox(
            height: 160,
            child: DrawerHeader(
                child: Column(
              children: [
                Image.asset('assets/images/logo.png', height: 80),
                const SizedBox(
                  height: 10,
                ),
                const Text(
                  '尋找貓貓',
                  style: TextStyle(fontSize: 18),
                ),
              ],
            )),
          ),
          user != null
              ? ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('設定'),
                  onTap: () {
                    Navigator.pushNamed(context, '/setting');
                  },
                )
              : const SizedBox(),
          user != null
              ? ListTile(
                  leading: const Icon(Icons.group),
                  title: const Text('朋友'),
                  onTap: () {
                    Navigator.pushNamed(context, '/friends');
                  },
                )
              : const SizedBox(),
          user != null
              ? ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('圖鑑'),
                  onTap: () {
                    // Update the state of the app.
                    // ...
                  },
                )
              : const SizedBox(),
          ListTile(
            leading: const Icon(Icons.menu_book),
            title: const Text('劇情'),
            onTap: () {
              // Update the state of the app.
              // ...
            },
          ),
          user != null
              ? ListTile(
                  leading: const Icon(Icons.logout),
                  title: const Text('登出'),
                  onTap: () async {
                    http.Response res = await http.post(uri(domain, '/logout'),
                        body: jsonEncode({'session': user.session}));
                    if (res.statusCode != 200) {
                      throw (res.statusCode);
                    }
                    debugPrint(res.body);
                    Map<String, dynamic> j = jsonDecode(res.body);
                    if (context.mounted && j['error'] != "") {
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                        content: Text(j['error']),
                      ));
                      return;
                    }
                    // clear user data
                    ref.read(userDataProvider.notifier).state = null;
                    // goto home page(login page)
                    if (context.mounted) {
                      Navigator.pushReplacementNamed(context, '/');
                    }
                  },
                )
              : ListTile(
                  leading: const Icon(Icons.login),
                  title: const Text('登入'),
                  onTap: () {
                    // goto home page(login page)
                    Navigator.pushReplacementNamed(context, '/');
                  },
                ),
        ],
      ),
    );
  }
}

class UserField extends ConsumerWidget {
  const UserField({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final String name = ref.watch(userDataProvider)?.name ?? '';
    final int caughtCats = ref.watch(userDataProvider)?.cats ?? 0;
    final String? profile = ref.watch(userDataProvider)?.profile;
    final String email = ref.watch(userDataProvider)?.email ?? '';
    final int level = ref.watch(userDataProvider)?.level ?? 0;

    return ref.watch(userDataProvider) == null
        ? const SizedBox()
        : Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              SizedBox(
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
                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                    ),
                    child: InkWell(
                      onTap: () {
                        //TODO
                      },
                      splashColor: Colors.white.withOpacity(0.3),
                    ),
                  )),
              const SizedBox(
                width: 20,
              ),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  name,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.email,
                      size: 16,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Text(email, style: const TextStyle(fontSize: 15)),
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Row(children: [
                  const Text(
                    '🐈',
                    style: TextStyle(fontSize: 15),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Text(
                    '已抓到 $caughtCats 隻貓貓',
                    style: const TextStyle(fontSize: 15),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    'Lv. $level',
                    style: const TextStyle(fontSize: 15),
                  ),
                ]),
              ])
            ]),
          );
  }
}
