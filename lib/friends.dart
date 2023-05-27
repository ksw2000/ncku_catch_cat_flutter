import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:catch_cat/util.dart';
import 'package:catch_cat/data.dart';
import 'package:catch_cat/friend.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;

class FriendPage extends ConsumerStatefulWidget {
  const FriendPage({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FriendPageState();
}

class _FriendPageState extends ConsumerState<FriendPage> {
  final _addUserByIDCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _addUserByIDCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  static const titleTextStyle = TextStyle(fontSize: 20);
  static const separator = SizedBox(
    height: 10,
  );

  @override
  Widget build(BuildContext context) {
    final invitingList = _generateFutureBuilder(false);
    final friendList = _generateFutureBuilder(true);

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('朋友'),
        ),
        body: SafeArea(
            child: Scrollbar(
                controller: _scrollCtrl,
                child: SingleChildScrollView(
                    controller: _scrollCtrl,
                    child: Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 10, horizontal: 10),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '加好友',
                                style: titleTextStyle,
                              ),
                              separator,
                              Row(
                                children: [
                                  // https://stackoverflow.com/questions/45986093/textfield-inside-of-row-causes-layout-exception-unable-to-calculate-size
                                  Flexible(
                                      child: TextField(
                                    controller: _addUserByIDCtrl,
                                    decoration: const InputDecoration(
                                        border: OutlineInputBorder(),
                                        hintText: '好友 ID',
                                        prefixIcon: Icon(Icons.search)),
                                    keyboardType: TextInputType.number,
                                  )),
                                  TextButton(
                                      onPressed: _inviteFriend,
                                      child: const Text('申請')),
                                ],
                              ),
                              separator,
                              Row(
                                children: [
                                  Text(
                                    '我的 ID: ${ref.watch(userDataProvider)?.id.toString()}',
                                    style: const TextStyle(fontSize: 14),
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  TextButton(
                                      onPressed: () => _copyID(),
                                      child: const Text('複製'))
                                ],
                              ),
                              separator,
                              invitingList,
                              friendList
                            ]))))));
  }

  void _copyID() async {
    await Clipboard.setData(
        ClipboardData(text: ref.read(userDataProvider)?.id.toString() ?? ""));
    if (mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('已複製')));
    }
  }

  FutureBuilder<List<FriendData>> _generateFutureBuilder(bool accepted) {
    return FutureBuilder<List<FriendData>>(
      future: _getFriendList(accepted),
      builder:
          (BuildContext context, AsyncSnapshot<List<FriendData>> snapshot) {
        if (snapshot.hasData) {
          return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                snapshot.data!.isNotEmpty
                    ? Text(accepted ? '好友列表' : '好友申請', style: titleTextStyle)
                    : const SizedBox(),
                ...snapshot.data!
                    .map((e) => FriendElement(
                          data: e,
                          accepted: accepted,
                        ))
                    .toList(),
                snapshot.data!.isNotEmpty ? separator : const SizedBox()
              ]);
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
    );
  }

  Future<List<FriendData>> _getFriendList(bool accepted) async {
    http.Response res = await http.post(
        uri(domain, accepted ? '/friends/list' : '/friends/inviting_me'),
        body: jsonEncode({
          'session': ref.read(userDataProvider)?.session,
        }));
    debugPrint(res.body);

    if (res.statusCode != 200) {
      return [];
    }

    Map<String, dynamic> j = jsonDecode(res.body);
    if (j['error'] != "") {
      debugPrint(j['error']);
    }

    return (j['list'] as List<dynamic>)
        .map((e) => FriendData.fromMap(e))
        .toList();
  }

  _inviteFriend() async {
    http.Response res = await http.post(uri(domain, '/friend/invite'),
        body: jsonEncode({
          'session': ref.read(userDataProvider)?.session,
          'finding_uid': int.parse(_addUserByIDCtrl.text),
        }));
    debugPrint(res.body);
    if (mounted && res.statusCode == 201) {
      _addUserByIDCtrl.text = "";
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('已申請，等待對方回覆'),
      ));
    }
    Map<String, dynamic> j = jsonDecode(res.body);
    if (mounted && j['error'] != "") {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(j['error']),
      ));
    } else {
      setState(() {});
    }
  }
}

class FriendElement extends ConsumerWidget {
  const FriendElement({Key? key, required this.accepted, required this.data})
      : super(key: key);
  final FriendData data;
  final bool accepted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
        child: ListTile(
      dense: true,
      visualDensity: const VisualDensity(vertical: 3),
      leading: SizedBox(
          height: 50,
          width: 50,
          child: Ink(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: data.profile != null
                    ? Image.network(
                        uri(domain, data.profile!).toString(),
                        width: 50,
                      ).image
                    : Image.asset(
                        defaultProfile,
                        width: 50,
                      ).image,
                fit: BoxFit.cover,
              ),
              borderRadius: const BorderRadius.all(Radius.circular(10)),
            ),
            child: InkWell(
              onTap: () {
                showFriendInfo(context, data, false);
              },
              splashColor: Colors.white.withOpacity(0.3),
            ),
          )),
      title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
                decoration: BoxDecoration(
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  border: Border.all(color: Colors.brown),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(3.0),
                  child: Text('Lv. ${data.level}',
                      style:
                          const TextStyle(fontSize: 13, color: Colors.brown)),
                )),
            const SizedBox(
              width: 8,
            ),
            Text(data.name, style: const TextStyle(fontSize: 17)),
            const SizedBox(
              width: 8,
            ),
            Text('${humanReadTime(data.lastLogin)}上線',
                style: const TextStyle(fontSize: 13, color: Colors.brown)),
          ]),
      trailing: !accepted
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () {
                      _acceptOrDeclineOrDeleteFriend(
                          context, ref, data.id, "/friend/decline");
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.red,
                    )),
                IconButton(
                    onPressed: () {
                      _acceptOrDeclineOrDeleteFriend(
                          context, ref, data.id, "/friend/agree");
                    },
                    icon: const Icon(Icons.check, color: Colors.green)),
              ],
            )
          : TextButton(
              child: const Text('解除好友'),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("確定與 ${data.name} 解除好友？"),
                        actions: [
                          TextButton(
                              child: const Text("先不要"),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                          OutlinedButton(
                              child: const Text(
                                "確定",
                              ),
                              onPressed: () {
                                _acceptOrDeclineOrDeleteFriend(
                                    context, ref, data.id, "/friend/delete");
                                Navigator.pop(context);
                                // TODO
                              }),
                        ],
                      );
                    });
              },
            ),
    ));
  }

  static Future _acceptOrDeclineOrDeleteFriend(
      BuildContext context, WidgetRef ref, int friendID, String request) async {
    http.Response res = await http.post(uri(domain, request),
        body: jsonEncode({
          'session': ref.watch(userDataProvider)?.session,
          'friend_uid': friendID,
        }));
    debugPrint(res.body);
    if (res.statusCode != 200 && res.statusCode != 201) {
      throw (res.statusCode);
    }
    Map<String, dynamic> j = jsonDecode(res.body);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(j['error'] != '' ? (j['error'] as String) : "成功"),
        // TODO 刷新頁面
      ));
    }
  }
}
