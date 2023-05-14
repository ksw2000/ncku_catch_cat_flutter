import 'package:flutter/material.dart';
import 'package:catch_cat/data.dart';

class PlayGround extends StatefulWidget {
  const PlayGround({super.key, required this.data});
  final PlayData data;
  @override
  State<PlayGround> createState() => _PlayGroundState();
}

class _PlayGroundState extends State<PlayGround> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.data.name),
      ),
      body: Stack(children: [
        const Padding(
            padding: EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('Catched'),
                Text(
                  '0／10',
                  style: TextStyle(fontSize: 25),
                )
              ],
            )),
        Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/cat (1).png',
              width: 80,
            ),
            const SizedBox(
              height: 10,
            ),
            const Text(
              '300M',
              style: TextStyle(fontSize: 25),
            )
          ],
        ))
      ]),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   tooltip: 'Catch',
      //   child: const Icon(Icons.catching_pokemon),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
