import 'dart:convert';

import 'package:catch_cat/data.dart';
import 'package:catch_cat/util.dart';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class ProfilePhoto extends ConsumerStatefulWidget {
  const ProfilePhoto({Key? key, required this.size}) : super(key: key);
  final double size;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfilePhotoState();
}

class _ProfilePhotoState extends ConsumerState<ProfilePhoto> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: widget.size,
      width: widget.size,
      child: Ink(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: ref.watch(userDataProvider)?.profile != null
                ? Image.network(
                    uri(domain, ref.watch(userDataProvider)!.profile!)
                        .toString(),
                    width: widget.size,
                    scale: 1,
                  ).image
                : Image.asset(
                    defaultProfile,
                    width: widget.size,
                    scale: 1,
                  ).image,
            fit: BoxFit.cover,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(10)),
        ),
        child: InkWell(
          onTap: () {
            _showPickFile();
          },
          splashColor: Colors.white.withOpacity(0.3),
        ),
      ),
    );
  }

  Future _showPickFile() async {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('上傳新頭貼'),
            // content:
            actions: [
              TextButton(
                  child: const Text(
                    "先不要",
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              OutlinedButton(
                // icon: const Icon(Icons.upload),
                child: const Text('上傳'),
                onPressed: () {
                  Navigator.pop(context);
                  _pickProfile();
                },
              ),
            ],
          );
        });
  }

  Future _pickProfile() async {
    // when using android
    // if not set withData: true, the file.bytes will be null
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(withData: true);
    if (result != null) {
      PlatformFile file = result.files.first;
      if (file.bytes != null) {
        final req =
            http.MultipartRequest("POST", uri(domain, "/upload/profile"));
        req.files.add(http.MultipartFile.fromBytes(
            'profile', file.bytes!.toList(),
            filename: file.name));
        final res = await req.send();
        final body = await res.stream.bytesToString();
        Map<String, dynamic> j = jsonDecode(body);
        jsonDecode(body);
        if (mounted && j['error'] != '') {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(j['error'] as String),
          ));
        }
        String path = j['path'];
        if (mounted && res.statusCode == 201) {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('更換頭貼'),
                  content: Column(mainAxisSize: MainAxisSize.min, children: [
                    SizedBox(
                      height: 80,
                      width: 80,
                      child: Ink(
                          decoration: BoxDecoration(
                        image: DecorationImage(
                          image: Image.network(
                            uri(domain, path).toString(),
                            width: 80,
                            scale: 1,
                          ).image,
                          fit: BoxFit.cover,
                        ),
                        borderRadius:
                            const BorderRadius.all(Radius.circular(10)),
                      )),
                    )
                  ]),
                  actions: [
                    TextButton(
                        child: const Text(
                          "取消",
                        ),
                        onPressed: () {
                          Navigator.pop(context);
                        }),
                    OutlinedButton(
                        child: const Text(
                          "確定",
                        ),
                        onPressed: () async {
                          await _updateProfile(path);
                          if (mounted) {
                            Navigator.pop(context);
                          }
                        }),
                  ],
                );
              });
        }
        debugPrint(body);
      }
    }
  }

  Future _updateProfile(String path) async {
    http.Response res = await http.post(uri(domain, '/user/update/profile'),
        body: jsonEncode(
            {"session": ref.read(userDataProvider)!.session, "path": path}));
    debugPrint(res.body);
    Map<String, dynamic> j = jsonDecode(res.body);

    final user = ref.read(userDataProvider)!.copy();
    user.profile = path;
    ref.read(userDataProvider.notifier).state = user;
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(j['error'] != "" ? j['error'] : "完成"),
      ));
    }
  }
}
