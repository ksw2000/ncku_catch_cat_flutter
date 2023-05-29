import 'dart:async';
import 'dart:convert';

import 'package:catch_cat/data.dart';
import 'package:catch_cat/friend.dart';
import 'package:catch_cat/util.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;

const catchingThreshold = 10;

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

final _friendPositionMarkers = StateProvider<List<Marker>>((ref) {
  return [];
});

class _PlayGroundState extends ConsumerState<PlayGround> {
  LatLng _currentPosition = LatLng(initLatitude, initLongitude);
  Timer? _timer;
  final _mapController = MapController();
  int timeCount = 0;
  PlayThemeData? data;
  bool showFriendPosition = true;

  @override
  void initState() {
    super.initState();
    data = ref.read(playDataProvider);
    _updatePositionPeriodically();
    // load cats
    if (data != null) {
      _loadCats(data!.id);
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
      _updatePositionPeriodically();
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
              center: _currentPosition,
              zoom: initZoom,
              maxZoom: maxZoom,
              onPositionChanged: (MapPosition position, bool hasGesture) {
                if (hasGesture) {
                  ref.read(fixGPSProvider.notifier).state = false;
                }
              }),
          // nonRotatedChildren: [
          //   RichAttributionWidget(
          //     attributions: [
          //       TextSourceAttribution('OpenStreetMap contributors',
          //           onTap: () => {
          //                 //launchUrl(Uri.parse('https://openstreetmap.org/copyright')
          //               }),
          //     ],
          //   ),
          // ],
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.app',
            ),
            MarkerLayer(markers: [
              Marker(
                point: _currentPosition,
                width: 15,
                height: 15,
                builder: (context) {
                  return const Icon(
                    Icons.circle,
                    color: Colors.lightBlue,
                    shadows: [
                      Shadow(
                        color: Colors.white,
                        blurRadius: 10,
                        offset: Offset(0, 0),
                      ),
                    ],
                    size: 15,
                  );
                },
              ),
              ...ref.watch(_friendPositionMarkers)
            ]),
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
                bottom: 10,
                left: 10,
                child: InkWell(
                    onTap: _showCat,
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
                          obscureDistance(
                              ref.watch(closestCatProvider)?.distance.toInt() ??
                                  0),
                          style: const TextStyle(fontSize: 18),
                        )
                      ],
                    )))),
        Positioned(
            right: 10,
            bottom: 10,
            child: TranslucentContainer(
                child: Column(children: [
              IconButton(
                onPressed: _showSetting,
                icon: const Icon(Icons.settings),
              ),
              IconButton(
                onPressed: () {
                  // move to the current position
                  _mapController.move(_currentPosition, initZoom);
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
        // Align(
        //   alignment: Alignment.bottomCenter,
        //   child: Padding(
        //       padding: const EdgeInsets.symmetric(vertical: 10),
        //       child: Text(
        //         '${_currentPosition.latitude}, ${_currentPosition.longitude}',
        //         style: const TextStyle(color: Colors.grey),
        //       )),
        // )
      ]),
    );
  }

  void _showCat() {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(ref.watch(closestCatProvider)!.cat.name),
            content: Column(mainAxisSize: MainAxisSize.min, children: [
              Image.asset(
                '${ref.watch(closestCatProvider)?.cat.thumbnail}',
                width: 65,
              ),
              const SizedBox(
                height: 15,
              ),
              Text(ref.watch(closestCatProvider)!.cat.description),
              const SizedBox(
                height: 5,
              ),
              Text(
                  '分數：${ref.watch(closestCatProvider)!.cat.weight} 距離：${ref.watch(closestCatProvider)!.distance} 公尺'),
              const SizedBox(
                height: 5,
              ),
              ref.watch(closestCatProvider) != null &&
                      ref.watch(closestCatProvider)!.distance <
                          catchingThreshold
                  ? TextButton(
                      onPressed: () async {
                        if (ref.watch(closestCatProvider) != null) {
                          await _catchCat(
                              ref.watch(closestCatProvider)!.cat.id);
                          // after catching update cat list
                          _loadCats(data!.id);
                        }
                      },
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.front_hand,
                            size: 14,
                          ),
                          SizedBox(
                            width: 5,
                          ),
                          Text('抓貓貓')
                        ],
                      ))
                  : const SizedBox()
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

  void _showSetting() {
    bool shareGPS = ref.read(userDataProvider)?.shareGPS ?? false;
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('設定'),
            content: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Column(mainAxisSize: MainAxisSize.min, children: [
                Row(
                  children: [
                    Switch(
                      value: shareGPS,
                      onChanged: (bool value) {
                        setState(() {
                          shareGPS = value;
                        });
                        ref.read(userDataProvider)?.setShareGPS(value);
                      },
                    ),
                    const Text("向好友分享我的位置")
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Switch(
                      value: showFriendPosition,
                      onChanged: (bool value) {
                        setState(() {
                          showFriendPosition = value;
                        });
                        if (!value) {
                          ref.read(_friendPositionMarkers.notifier).state = [];
                        } else {
                          // get friends position without waiting
                          _getFriendsPosition();
                        }
                        showFriendPosition = value;
                      },
                    ),
                    const Text("顯示好友的位置")
                  ],
                )
              ]);
            }),
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

  void _updatePositionPeriodically() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _getPosition().then((position) {
        _currentPosition = LatLng(position.latitude, position.longitude);
        if (mounted == false) return;
        if (ref.read(fixGPSProvider)) {
          _mapController.move(_currentPosition, _mapController.zoom);
        }
        // find the latest uncaught cat
        const Distance distance = Distance();
        double closestDistance = double.maxFinite;
        Cat? closetCat;
        ref.read(catListDataProvider).forEach((Cat e) {
          double k = distance(e.position, _currentPosition);
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
        if (timeCount == 0) {
          // share my position to server
          _sharePositionToServer();
          // get friends position from server
          if (showFriendPosition) {
            _getFriendsPosition();
          }
        }
        timeCount = (timeCount + 1) % 30;
      }).onError((error, stackTrace) {});
    });
  }

  Future<Position> _getPosition() async {
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

  Future _loadCats(int themeID) async {
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
        (j['cat_list'] as List).map((e) => Cat.fromMap(e)).toList();
    ref.read(catListDataProvider.notifier).state = catData;
  }

  void _sharePositionToServer() async {
    http.Response res = await http.post(uri(domain, '/user/update/gps'),
        body: jsonEncode({
          'session': ref.read(userDataProvider)?.session,
          'lat': _currentPosition.latitude,
          'lng': _currentPosition.longitude
        }));
    debugPrint(res.body);
  }

  Future _getFriendsPosition() async {
    http.Response res = await http.post(uri(domain, '/friends/position'),
        body: jsonEncode({
          'session': ref.read(userDataProvider)?.session,
          'theme_id': ref.read(playDataProvider)?.id
        }));
    debugPrint(res.body);
    Map<String, dynamic> j = jsonDecode(res.body);
    List<FriendData> friends =
        (j['list'] as List).map((e) => FriendData.fromMap(e)).toList();
    List<Marker> markers = [];
    for (var e in friends) {
      markers.add(Marker(
        point: LatLng(e.lat, e.lng),
        width: 150,
        height: 40,
        anchorPos: AnchorPos.align(AnchorAlign.right),
        builder: (context) {
          return FriendMarker(data: e);
        },
      ));
    }
    ref.read(_friendPositionMarkers.notifier).state = markers;
  }

  Future _catchCat(int catID) async {
    http.Response res = await http.post(uri(domain, '/cat/catching'),
        body: jsonEncode(
            {'session': ref.read(userDataProvider)?.session, 'cat_id': catID}));
    debugPrint(res.body);
    Map<String, dynamic> j = jsonDecode(res.body);
    if (j['error'] != '') {
      throw (j['error']);
    }
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
        child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10.0),
            child: child));
  }
}

class FriendMarker extends StatelessWidget {
  const FriendMarker({Key? key, required this.data}) : super(key: key);
  final FriendData data;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Container(
          width: 35.0,
          height: 35.0,
          decoration: BoxDecoration(
              border: Border.all(width: 3, color: Colors.white),
              shape: BoxShape.circle,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: data.profile != null
                      ? Image.network(uri(domain, data.profile!).toString())
                          .image
                      : Image.asset(defaultProfile).image)),
          child: InkWell(
            onTap: () {
              showFriendInfo(context, data, true);
            },
          )),
      const SizedBox(width: 10),
      Column(
          // mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(children: [
              Text(data.name,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..color = Colors.white
                        ..strokeWidth = 2,
                      fontSize: 12,
                      fontWeight: FontWeight.bold)),
              Text(data.name,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontSize: 12, fontWeight: FontWeight.bold))
            ]),
            Stack(
              children: [
                Text(humanReadTime(data.lastLogin),
                    style: TextStyle(
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..color = Colors.white
                          ..strokeWidth = 2,
                        overflow: TextOverflow.ellipsis,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
                Text(humanReadTime(data.lastLogin),
                    style: const TextStyle(
                        overflow: TextOverflow.ellipsis,
                        fontSize: 12,
                        fontWeight: FontWeight.bold)),
              ],
            )
          ])
    ]);
  }
}
