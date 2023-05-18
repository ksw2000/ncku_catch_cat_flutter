import 'package:flutter/material.dart';
import 'package:catch_cat/data.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';

class PlayGround extends StatefulWidget {
  const PlayGround({super.key, required this.data});
  final PlayData data;
  @override
  State<PlayGround> createState() => _PlayGroundState();
}

class _PlayGroundState extends State<PlayGround> {
  double _longitude = 0;
  double _latitude = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    updatePositionPeriodically();
  }

  // 畫面切換
  // @override
  // void deactivate() {
  //   super.deactivate();
  //   _timer?.cancel();
  // }

  @override
  Widget build(BuildContext context) {
    if (_timer == null) {
      updatePositionPeriodically();
    }
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
        )),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                _longitude == 0.0 && _latitude == 0.0
                    ? ''
                    : '$_latitude, $_longitude',
                style: const TextStyle(color: Colors.grey),
              )),
        )
      ]),

      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {},
      //   tooltip: 'Catch',
      //   child: const Icon(Icons.catching_pokemon),
      // ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  void updatePositionPeriodically() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _getPosition().then((position) {
        _latitude = position.latitude;
        _longitude = position.longitude;
        if (mounted == true) {
          setState(() {});
        }
      });
    });
  }

  Future<Position> _getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Permissions are denied, next time you could try
        // requesting permissions again (this is also where
        // Android's shouldShowRequestPermissionRationale
        // returned true. According to Android guidelines
        // your App should show an explanatory UI now.
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    return await Geolocator.getCurrentPosition();
  }
}
