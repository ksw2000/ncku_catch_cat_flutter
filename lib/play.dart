import 'package:flutter/material.dart';
import 'package:catch_cat/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';

class PlayGround extends ConsumerStatefulWidget {
  const PlayGround({super.key});
  @override
  ConsumerState<PlayGround> createState() => _PlayGroundState();
}

const initLongitude = 120.22062435767066;
const initLatitude = 22.997658959467252;
const initZoom = 16.0;
const maxZoom = 18.0;
const minZoom = 3.0;

class _PlayGroundState extends ConsumerState<PlayGround> {
  LatLng currentPosition = LatLng(initLatitude, initLongitude);
  Timer? _timer;
  final _mapController = MapController();
  bool fixToCurrent = true;
  PlayData? data;

  @override
  void initState() {
    super.initState();
    updatePositionPeriodically();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  // 畫面切換
  // @override
  // void deactivate() {
  //   super.deactivate();
  //   _timer?.cancel();
  // }

  @override
  Widget build(BuildContext context) {
    data = ref.read(playDataProvider);
    if (_timer == null) {
      updatePositionPeriodically();
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(data?.name ?? ""),
        actions: [
          IconButton(
              icon: const Icon(Icons.workspace_premium),
              onPressed: () {
                Navigator.pushNamed(context, '/play/ranking');
              })
        ],
      ),
      body: Stack(children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
              center: currentPosition,
              zoom: initZoom,
              maxZoom: maxZoom,
              onPositionChanged: (MapPosition position, bool hasGesture) {
                if (hasGesture) {
                  fixToCurrent = false;
                }
              }),
          nonRotatedChildren: [
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors',
                    onTap: () => {
                          //launchUrl(Uri.parse('https://openstreetmap.org/copyright')
                        }),
              ],
            ),
          ],
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: currentPosition,
                  width: 20,
                  height: 20,
                  builder: (context) {
                    return const Icon(
                      Icons.radio_button_checked,
                      color: Colors.blue,
                      size: 30,
                    );
                  },
                ),
              ],
            ),
          ],
        ),
        Positioned(
            left: 5,
            top: 5,
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: const BorderRadius.all(Radius.circular(5))),
                child: const Padding(
                    padding: EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Text('Caught🐈'),
                        Text(
                          '0 / 10',
                          style: TextStyle(fontSize: 25),
                        )
                      ],
                    )))),
        Positioned(
            bottom: 45,
            left: 5,
            child: Container(
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: const BorderRadius.all(Radius.circular(5))),
                child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/cat (1).png',
                          width: 65,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        const Text(
                          '300M',
                          style: TextStyle(fontSize: 18),
                        )
                      ],
                    )))),
        Positioned(
            right: 5,
            bottom: 45,
            child: Container(
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.all(Radius.circular(5))),
                child: Column(children: [
                  IconButton(
                    onPressed: () {
                      // move to the current position
                      _mapController.move(currentPosition, initZoom);
                      setState(() {
                        fixToCurrent = true;
                      });
                    },
                    icon: Icon(
                        fixToCurrent ? Icons.gps_fixed : Icons.gps_not_fixed),
                  ),
                  IconButton(
                      onPressed: () {
                        double zoom = _mapController.zoom;
                        LatLng center = _mapController.center;
                        if (zoom + .5 <= maxZoom) {
                          _mapController.move(center, zoom + 0.5);
                        }
                      },
                      icon: const Icon(Icons.add)),
                  IconButton(
                      onPressed: () {
                        double zoom = _mapController.zoom;
                        LatLng center = _mapController.center;
                        if (zoom - .5 >= minZoom) {
                          print(zoom);
                          _mapController.move(center, zoom - 0.5);
                        }
                      },
                      icon: const Icon(Icons.remove))
                ]))),
        Align(
          alignment: Alignment.bottomCenter,
          child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Text(
                '${currentPosition.latitude}, ${currentPosition.longitude}',
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
        currentPosition = LatLng(position.latitude, position.longitude);
        if (mounted == true) {
          if (fixToCurrent) {
            _mapController.move(currentPosition, _mapController.zoom);
          }
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
