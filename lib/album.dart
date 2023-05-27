import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:catch_cat/data.dart';
import 'package:catch_cat/util.dart';
import 'package:catch_cat/profile.dart';
import 'package:http/http.dart' as http;

class AlbumPage extends ConsumerStatefulWidget {
  const AlbumPage({Key? key}) : super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AlbumPageState();
}

class _AlbumPageState extends ConsumerState<AlbumPage> {
  max(int a, int b) {
    return a > b ? a : b;
  }

  min(int a, int b) {
    return a > b ? b : a;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('圖鑑'),
        ),
        body: SafeArea(
          child: FutureBuilder<List<CatKindData>>(
            future: _loadCats(),
            builder: (BuildContext context,
                AsyncSnapshot<List<CatKindData>> snapshot) {
              if (snapshot.hasData) {
                return GridView.count(
                  crossAxisCount:
                      min(5, max(1, MediaQuery.of(context).size.width ~/ 120)),
                  children:
                      snapshot.data!.map((e) => AlbumCard(data: e)).toList(),
                );
              } else if (snapshot.hasError) {
                return Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 16),
                          child: Text('Error: ${snapshot.error}'),
                        ),
                      ]),
                );
              }
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: CircularProgressIndicator(),
                    ),
                  ],
                ),
              );
            },
          ),
        ));
  }

  Future<List<CatKindData>> _loadCats() async {
    http.Response res = await http.post(uri(domain, '/cat/my_caught_kind'),
        body: jsonEncode({"session": ref.read(userDataProvider)?.session}));
    debugPrint(res.body);
    Map<String, dynamic> j = jsonDecode(res.body);
    if (mounted && j['error'] != "") {
      throw (j['error']);
    }
    return (j['list'] as List).map((e) => CatKindData.fromMap(e)).toList();
  }
}

class AlbumCard extends StatelessWidget {
  const AlbumCard({Key? key, required this.data}) : super(key: key);
  final CatKindData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: SizedBox(
          width: 200,
          height: 200,
          child: Ink(
            decoration: BoxDecoration(
                image: data.isCaught
                    ? DecorationImage(
                        image: Image.asset(
                          data.thumbnail,
                        ).image,
                        fit: BoxFit.contain,
                      )
                    : DecorationImage(
                        image: Image.asset('assets/images/cat-not-caught.gif')
                            .image,
                        fit: BoxFit.cover,
                      ),
                borderRadius: const BorderRadius.all(Radius.circular(10))),
            child: InkWell(
              onTap: () {
                if (!data.isCaught) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('還沒有解鎖'),
                  ));
                } else {
                  showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text(data.name),
                          content:
                              Column(mainAxisSize: MainAxisSize.min, children: [
                            Image.asset(
                              data.thumbnail,
                              width: 100,
                            ),
                            const SizedBox(
                              height: 15,
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.max,
                              children: [
                                Container(
                                    decoration: BoxDecoration(
                                      borderRadius: const BorderRadius.all(
                                          Radius.circular(10)),
                                      border: Border.all(color: Colors.brown),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(3.0),
                                      child: Text('${data.weight} 分',
                                          style: const TextStyle(
                                              fontSize: 13,
                                              color: Colors.brown)),
                                    )),
                              ],
                            ),
                            const SizedBox(
                              height: 5,
                            ),
                            Text(data.description),
                          ]),
                          actions: [
                            OutlinedButton(
                                child: const Text(
                                  "OK",
                                ),
                                onPressed: () {
                                  Navigator.pop(context);
                                }),
                          ],
                        );
                      });
                }
              },
              splashColor: Colors.white.withOpacity(0.3),
            ),
          )),
      // Padding(
      //     padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
      //     child: Text(data.name, style: const TextStyle(fontSize: 18))),
    );
  }
}
