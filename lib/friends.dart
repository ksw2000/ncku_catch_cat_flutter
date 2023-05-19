import 'package:flutter/material.dart';
import 'package:catch_cat/data.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    List<Widget> friendList = _getFriendList();
    List<Widget> friendInvitingList = _getFriendInvitingList();
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
                            vertical: 20, horizontal: 20),
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                '加好友',
                                style: titleTextStyle,
                              ),
                              separator,
                              TextField(
                                controller: _addUserByIDCtrl,
                                decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: '好友 ID',
                                    prefixIcon: Icon(Icons.search)),
                                keyboardType: TextInputType.number,
                              ),
                              separator,
                              Center(
                                child: OutlinedButton(
                                    onPressed: () {}, child: const Text('申請')),
                              ),
                              separator,
                              friendInvitingList.isNotEmpty
                                  ? const Text('好友申請', style: titleTextStyle)
                                  : const SizedBox(),
                              // ---------------------------- //
                              friendInvitingList.isNotEmpty
                                  ? separator
                                  : const SizedBox(),
                              ...friendInvitingList,
                              friendInvitingList.isNotEmpty
                                  ? separator
                                  : const SizedBox(),
                              // ---------------------------- //
                              friendList.isNotEmpty
                                  ? const Text('好友列表', style: titleTextStyle)
                                  : const SizedBox(),
                              friendList.isNotEmpty
                                  ? separator
                                  : const SizedBox(),
                              ...friendList,
                              friendList.isNotEmpty
                                  ? separator
                                  : const SizedBox(),
                            ]))))));
  }

  List<Widget> _getFriendList() {
    return debugFriendDataList.map((e) => FriendElement(data: e)).toList();
  }

  List<Widget> _getFriendInvitingList() {
    return debugFriendDataInvitingList
        .map((e) => FriendElement(data: e))
        .toList();
  }
}

class FriendElement extends StatelessWidget {
  const FriendElement({Key? key, required this.data}) : super(key: key);
  final FriendData data;

  @override
  Widget build(BuildContext context) {
    return Card(
        child: ListTile(
      dense: true,
      visualDensity: VisualDensity(vertical: 3),
      leading: SizedBox(
          height: 50,
          width: 50,
          child: Ink(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: data.profile != null
                    ? Image.network(
                        data.profile!,
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
                //TODO
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
            Text(data.name, style: const TextStyle(fontSize: 17))
          ]),
      trailing: data.inviting
          ? Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                    onPressed: () {
                      // TODO
                    },
                    icon: const Icon(
                      Icons.close,
                      color: Colors.red,
                    )),
                IconButton(
                    onPressed: () {
                      // TODO
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
                        title: Text("確定與 ${data.name} 解解好友？"),
                        actions: [
                          TextButton(
                              child: const Text("先不要"),
                              onPressed: () {
                                Navigator.pop(context);
                              }),
                          TextButton(
                              child: const Text(
                                "確定",
                                style: TextStyle(color: Colors.red),
                              ),
                              onPressed: () {
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
}
