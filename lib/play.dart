import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:catch_cat/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'dart:async';
import 'package:http/http.dart' as http;

import 'api.dart';

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

final fixGPSProvider = StateProvider((ref) {
  return false;
});

final isUserEnableGPSProvider = StateProvider<bool>((ref) {
  return true;
});

class _PlayGroundState extends ConsumerState<PlayGround> {
  LatLng currentPosition = LatLng(initLatitude, initLongitude);
  Timer? _timer;
  final _mapController = MapController();

  PlayThemeData? data;

  @override
  void initState() {
    super.initState();
    data = ref.read(playDataProvider);
    updatePositionPeriodically();
    // load cats
    if (data != null) {
      loadCats(data!.id);
    }
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
                  ref.read(fixGPSProvider.notifier).state = false;
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
        ref.watch(isUserEnableGPSProvider)
            ? const SizedBox()
            : const Center(
                child: TranslucentContainer(
                    child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.gps_not_fixed_outlined, size: 40),
                  Text(
                    '請開啟 GPS',
                    style: TextStyle(fontSize: 20),
                  )
                ],
              ))),
        ref.watch(playDataProvider) == null
            ? const SizedBox()
            : Positioned(
                left: 5,
                top: 5,
                child: TranslucentContainer(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text('🐈', style: TextStyle(fontSize: 20)),
                    Text(
                      '${numOfCaught(ref.watch(catListDataProvider)).toString()} / ${ref.watch(catListDataProvider).length.toString()}',
                      style: const TextStyle(fontSize: 20),
                    )
                  ],
                ))),
        ref.watch(closestCatProvider) == null
            ? const SizedBox()
            : Positioned(
                bottom: 45,
                left: 5,
                child: InkWell(
                    onTap: () {
                      showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title:
                                  Text(ref.watch(closestCatProvider)!.cat.name),
                              content: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(
                                      '${ref.watch(closestCatProvider)?.cat.thumbnail}',
                                      width: 65,
                                    ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Text(ref
                                        .watch(closestCatProvider)!
                                        .cat
                                        .description),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                        '分數：${ref.watch(closestCatProvider)!.cat.weight} 距離：${ref.watch(closestCatProvider)!.distance} 公尺')
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
                    },
                    child: TranslucentContainer(
                        child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          '${ref.watch(closestCatProvider)?.cat.thumbnail}',
                          width: 65,
                        ),
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          '${ref.watch(closestCatProvider)?.distance.toString()}M',
                          style: const TextStyle(fontSize: 18),
                        )
                      ],
                    )))),
        Positioned(
            right: 5,
            bottom: 45,
            child: TranslucentContainer(
                child: Column(children: [
              IconButton(
                onPressed: () {
                  // move to the current position
                  _mapController.move(currentPosition, initZoom);
                  ref.read(fixGPSProvider.notifier).state = true;
                },
                icon: Icon(ref.watch(fixGPSProvider)
                    ? Icons.gps_fixed
                    : Icons.gps_not_fixed),
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
    );
  }

  void updatePositionPeriodically() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      getPosition().then((position) {
        currentPosition = LatLng(position.latitude, position.longitude);
        if (mounted == false) return;
        if (ref.read(fixGPSProvider)) {
          _mapController.move(currentPosition, _mapController.zoom);
        }
        // setState(() {});
        // find the latest uncaught cat
        const Distance distance = Distance();
        double closestDistance = double.maxFinite;
        Cat? closetCat;
        ref.read(catListDataProvider).forEach((Cat e) {
          double k = distance(e.position, currentPosition);
          if (k < closestDistance && !e.isCaught) {
            closestDistance = k;
            closetCat = e;
          }
        });
        if (closetCat != null) {
          ref.read(closestCatProvider.notifier).state =
              LatestCat(distance: closestDistance, cat: closetCat!);
        } else {
          ref.read(closestCatProvider.notifier).state = null;
        }
      }).onError((error, stackTrace) {});
    });
  }

  Future<Position> getPosition() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      ref.read(isUserEnableGPSProvider.notifier).state = false;
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
        ref.read(isUserEnableGPSProvider.notifier).state = false;
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      ref.read(isUserEnableGPSProvider.notifier).state = false;
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    // When we reach here, permissions are granted and we can
    // continue accessing the position of the device.
    ref.read(isUserEnableGPSProvider.notifier).state = true;
    return await Geolocator.getCurrentPosition();
  }

  Future loadCats(int themeID) async {
    http.Response res = await http.post(uri(domain, '/theme'),
        body: jsonEncode({
          'session': ref.read(userDataProvider)?.session,
          'theme_id': themeID
        }));
    debugPrint(res.body);

    if (res.statusCode != 200) {
      return [];
    }
    Map<String, dynamic> j = jsonDecode(res.body);
    if (j['error'] != "") {
      debugPrint(j['error']);
      return;
    }
    List<Cat> catData =
        (j['cat_list'] as List<dynamic>).map((e) => Cat.fromMap(e)).toList();
    ref.read(catListDataProvider.notifier).state = catData;
  }
}

class LatestCat {
  const LatestCat({required this.distance, required this.cat});
  final double distance;
  final Cat cat;
}

final closestCatProvider = StateProvider<LatestCat?>((ref) {
  return null;
});

class TranslucentContainer extends StatelessWidget {
  const TranslucentContainer({Key? key, required this.child}) : super(key: key);
  final Widget child;
  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.8),
            borderRadius: const BorderRadius.all(Radius.circular(5))),
        child: Padding(padding: const EdgeInsets.all(10.0), child: child));
  }
}
