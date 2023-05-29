import 'package:catch_cat/data.dart';
import 'package:catch_cat/util.dart';

import 'package:flutter/material.dart';

void showFriendInfo(
    BuildContext context, FriendData data, bool showThemeState) {
  showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(data.name),
          content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                    child: SizedBox(
                  height: 80,
                  width: 80,
                  child: Ink(
                      decoration: BoxDecoration(
                    image: DecorationImage(
                      image: data.profile != null
                          ? Image.network(
                              uri(domain, data.profile!).toString(),
                              width: 80,
                            ).image
                          : Image.asset(
                              defaultProfile,
                              width: 80,
                            ).image,
                      fit: BoxFit.cover,
                    ),
                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                  )),
                )),
                const SizedBox(
                  height: 15,
                ),
                Text("Lv ${data.level} ‧ ${humanReadTime(data.lastLogin)}上線",
                    style: const TextStyle(fontSize: 16)),
                const SizedBox(
                  height: 5,
                ),
                Text(
                  "一共捕獲 ${data.cats} 隻貓貓 ‧${data.score} 分",
                  style: const TextStyle(fontSize: 16),
                ),
                showThemeState
                    ? const SizedBox(
                        height: 5,
                      )
                    : const SizedBox(),
                showThemeState
                    ? Text(
                        "此地圖中捕獲 ${data.themeCats} 隻貓貓 ${data.themeScore} 分",
                        style: const TextStyle(fontSize: 16),
                      )
                    : const SizedBox(),
              ]),
          actions: [
            TextButton(
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
