import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:catch_cat/data.dart';
import 'package:catch_cat/util.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class RankingPage extends ConsumerStatefulWidget {
  const RankingPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RankingPageState();
}

class _RankingPageState extends ConsumerState<RankingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('排名'),
        ),
        body: SafeArea(
            child: Padding(
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                child: Center(
                    child: FutureBuilder<List<RankingData>>(
                  future: _getRankList(ref.read(playDataProvider)?.id ?? 0),
                  builder: (BuildContext context,
                      AsyncSnapshot<List<RankingData>> snapshot) {
                    if (snapshot.hasData) {
                      List<Widget> widgets = [];
                      for (int i = 0; i < snapshot.data!.length; i++) {
                        widgets.add(RankingListElement(
                            data: snapshot.data![i], rank: i + 1));
                      }
                      return Column(children: widgets);
                    } else if (snapshot.hasError) {
                      return Column(
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
                          ]);
                    }

                    return const Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 60,
                          height: 60,
                          child: CircularProgressIndicator(),
                        ),
                      ],
                    );
                  },
                )))));
  }

  Future<List<RankingData>> _getRankList(int themeID) async {
    http.Response res = await http.post(uri(domain, '/friends/theme_rank'),
        body: jsonEncode({
          'session': ref.watch(userDataProvider)?.session,
          'theme_id': themeID,
        }));
    debugPrint(res.body);
    if (res.statusCode != 200) {
      throw ("HTTP ${res.statusCode}");
    }
    Map<String, dynamic> j = jsonDecode(res.body);
    if (j['error'] != '') {
      throw (j['error']);
    }
    return (j['sorted_list'] as List)
        .map((e) => RankingData.fromMap(e))
        .toList();
  }
}

class RankingData {
  RankingData(
      {required this.uid,
      required this.name,
      required this.score,
      required this.cats});
  RankingData.fromMap(Map<String, dynamic> j)
      : uid = j['uid'],
        name = j['name'],
        score = j['score'],
        cats = j['cats'];

  final int uid;
  final String name;
  final int score;
  final int cats;
}

class RankingListElement extends StatelessWidget {
  const RankingListElement({Key? key, required this.data, required this.rank})
      : super(key: key);
  final RankingData data;
  final int rank;
  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      leading: Container(
        decoration: const BoxDecoration(
          color: Colors.pinkAccent,
          shape: BoxShape.circle,
        ),
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text('$rank',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
      ),
      title: Text(data.name,
          style: const TextStyle(
              color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
      trailing: Text('${data.cats}🐈 ${data.score}分',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent)),
    ));
  }
}
