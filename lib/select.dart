import 'package:catch_cat/play.dart';
import 'package:catch_cat/data.dart';
import 'package:flutter/material.dart';

class SelectPage extends StatefulWidget {
  const SelectPage({super.key});
  @override
  State<SelectPage> createState() => _SelectPageState();
}

class _SelectPageState extends State<SelectPage> {
  final scrollCtrl = ScrollController();
  @override
  void dispose() {
    scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('選擇主題'),
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
                          PlayCard(
                              data: PlayData(
                                  name: '國立成功大學',
                                  thumbnail: 'assets/themes/ncku.png',
                                  id: 0)),
                          PlayCard(
                              data: PlayData(
                                  name: '台南孔廟商圈',
                                  thumbnail:
                                      'assets/themes/Confucius Temple.png',
                                  id: 1)),
                          PlayCard(
                              data: PlayData(
                                  name: '猴硐猫村',
                                  thumbnail:
                                      'assets/themes/Houtong Cats Village.jpg',
                                  id: 1)),
                        ],
                      )),
                ))));
  }
}

class PlayCard extends StatefulWidget {
  const PlayCard({super.key, required this.data});
  final PlayData data;
  @override
  State<PlayCard> createState() => _PlayCardState();
}

class _PlayCardState extends State<PlayCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(mainAxisAlignment: MainAxisAlignment.end, children: [
        SizedBox(
            height: 200,
            child: Ink(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: Image.asset(
                    widget.data.thumbnail,
                  ).image,
                  fit: BoxFit.cover,
                ),
                borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10)),
              ),
              child: InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => PlayGround(data: widget.data)));
                },
                splashColor: Colors.white.withOpacity(0.3),
              ),
            )),
        Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
            child:
                Text(widget.data.name, style: const TextStyle(fontSize: 18))),
      ]),
    );
  }
}
