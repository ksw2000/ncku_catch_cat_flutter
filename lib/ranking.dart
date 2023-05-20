import 'package:flutter/material.dart';
import 'package:catch_cat/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
                    const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                child: Center(
                    child: Column(children: generateRankingElements())))));
  }

  //debugRankData
  List<Widget> generateRankingElements() {
    List<Widget> widgets = [];
    int i = 0;
    debugRankDataList.forEach((e) {
      i++;
      widgets.add(RankingListElement(rank: i, name: e.name, score: e.cats));
    });
    return widgets;
  }
}

class RankingListElement extends StatelessWidget {
  const RankingListElement(
      {Key? key, required this.rank, required this.name, required this.score})
      : super(key: key);
  final int rank;
  final String name;
  final int score;
  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      leading: Container(
        decoration: const BoxDecoration(
          color: Colors.pinkAccent,
          shape: BoxShape.circle,
          // borderRadius: BorderRadius.all(Radius.circular(5))
        ),
        child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text('$rank',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold))),
      ),
      title: Text(name,
          style: const TextStyle(
              color: Colors.pinkAccent, fontWeight: FontWeight.bold)),
      trailing: Text('$score',
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.pinkAccent)),
    ));
  }
}
