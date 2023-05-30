import 'package:catch_cat/data.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StoryPage extends ConsumerStatefulWidget {
  const StoryPage({Key? key}) : super(key: key);
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _StoryPageState();
}

class _StoryPageState extends ConsumerState<StoryPage> {
  final _scrollCtrl = ScrollController();

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("劇情"),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SafeArea(
            child: Scrollbar(
                controller: _scrollCtrl,
                child: SingleChildScrollView(
                    controller: _scrollCtrl,
                    child: Center(
                      child: Container(
                          constraints: const BoxConstraints(maxWidth: 650),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          child: Column(
                              children: getStory()
                                  .map((e) => StoryListElement(data: e))
                                  .toList())),
                    )))));
  }

  List<StoryData> getStory() {
    if (ref.read(userDataProvider) == null) {
      return [];
    }
    final level = ref.read(userDataProvider)!.level;
    List<StoryData> defaultStory = <StoryData>[
      StoryData(
          title: '第一章：迷失的小貓',
          abstraction: '一隻可愛的小貓在外迷路了，它試著找回家的路，遇到了一群善良的人和其他動物，最終成功地找到了它的主人。',
          content:
              """春天的午後，陽光灑在靜謐的小鎮上，一隻細小的灰色小貓走在街頭。它叫做米露，一隻擁有明亮綠眼的可愛小貓。米露原本和它的主人一起生活在一個舒適的家中，但一不小心，它從開放的門口溜出去，迷路了。
小貓四處張望，但一片陌生的景色使它感到困惑。它試圖找到回家的路，但是每個轉角都看起來一樣。米露開始感到驚慌，它不知道該怎麼辦。
突然，一位善良的女孩注意到了迷路的小貓。她名叫艾莉，是這個小鎮的居民。艾莉心生憐憫，走到小貓身邊。「嗨，小貓，你好可愛！你迷路了嗎？」她輕聲說道。
米露抬起頭，眼神充滿了希望。它發出一聲輕輕的「喵」聲，彷彿在向艾莉求助。
艾莉彎下身子撫摸著米露的毛。「別擔心，小貓。我會幫助你找到回家的路。」
艾莉和米露一起開始了尋找回家的冒險。他們問路人、檢查每個巷子，但是沒有任何線索。正當他們感到絕望的時候，一隻友善的老狗出現在他們面前。
「嗨，你們在找什麼？」老狗問道。
艾莉解釋了米露迷路的情況。老狗微笑著說：「我們一起去找找吧，也許我能提供一些幫助。」
三個新朋友一起努力尋找回家的路。他們問問題，尋找線索，跟著每個可能的方向走。他們在街道上行走，經過公園和商店，希望能找到一些熟悉的地標。
在旅途中，他們遇到了其他的動物朋友，包括一隻聰明的松鼠和一隻友善的鳥類。這些動物們共同合作，用自己的方式幫助米露尋找回家的路。
松鼠利用它的敏銳觀察力，迅速跳躍在樹枝之間，尋找任何熟悉的地標或標誌。鳥類在空中盤旋，用它的鳥瞰視角搜索整個小鎮，希望找到米露家附近的指引。
最終，他們來到了小鎮的郊外，眼前出現了一棟熟悉的房子。米露的心跳加速，它知道它終於回到家了。
米露衝向家門，門開了，它的主人正焦急地等待著。主人看見米露，立刻擁抱著它。「我以為再也見不到你了！謝謝你們幫助我的貓找到回家的路！」主人感激地對艾莉、老狗、松鼠和鳥類說。
艾莉微笑著回應：「我們只是幫助一個需要幫助的小貓而已。友情和助人之心是我們共同的力量。」
米露擁有了一個難忘的冒險回憶，它學會了友誼的價值，以及堅持不懈的重要性。這個故事也在小鎮上傳開，成為了人們關於友情和助人精神的美好故事。
從此以後，米露和艾莉、老狗、松鼠和鳥類成為了最好的朋友。他們一起度過了無數快樂的時光，並永遠保持著對彼此的關愛和支持。
"""),
      StoryData(
          title: '第二章：貓貓救援行動',
          abstraction: '一隻勇敢的貓咪發現一隻小鳥掉到了水池中無法自救，它毫不猶豫地跳入水中，用巧妙的方式救出了小鳥，成為了英雄。',
          content:
              """風雨如瀑布般傾瀉而下，夜晚的街道被暴雨淹沒。在這個狼藉的夜晚，一隻名叫小奇的黑白貓躲在一棟廢棄的建築物附近。它瞇著眼睛，尋找一點遮蔽雨水的地方。
突然，一聲淒厲的哀嚎劃破夜空，穿透了小奇的耳朵。它的心臟猛地一跳，立即警覺。小奇迅速擦去臉上的雨水，朝聲音的方向移動。
貓咪小奇來到一個深淵的邊緣。它仔細地俯瞰下面的景象，發現一隻小狗被困在深淵的水中，無法自救。小奇的心被急迫的情感所支配，它知道必須立即行動。
小奇四處尋找可以施展救援的方法。它找到一根棍子，但由於水流湍急，棍子似乎無法達到小狗。小奇必須找到更聰明的辦法。
貓咪小奇注意到附近有一根懸崖邊的繩子。這是它的唯一希望，但是它得快速思考如何使用這根繩子。
小奇迅速跳到懸崖邊，咬住繩子的一端，然後小心地將另一端放入深淵中。小狗看到繩子後，奮力游向它，但水流太強大，它無法抓住繩子。
貓咪小奇沒有放棄，它拉緊繩子，用自己的力量將小狗拉近。繩子繼續滑動，小奇全力以赴地拉扯著繩子，盡管淋著大雨，卻並不放棄。終於，小狗抓住了繩子，小奇使出最後的力氣，將它成功拉出了深淵。
小狗和小奇一起爬上岸邊，它們疲憊不堪但心滿意足。小狗舔了舔小奇的臉，以表達它的感激之情。
就在這個時候，一群居民聽到了這個感人的故事，他們急忙趕來，目睹了小奇的英勇行為。他們被這個小貓的勇氣和無私感動，紛紛稱贊它為真正的英雄。
消息傳開後，小奇成為了小鎮的名人。人們給它戴上勇氣勳章，為它舉辦了一場盛大的頒獎典禮，表彰它的英勇行為。
小奇並不在意這些榮譽，它心懷著滿滿的幸福，因為它成功地救助了一個生命。從那天起，小奇和小狗成為了最好的朋友，它們在一起度過了許多快樂的時光。
「貓貓救援行動」的故事傳遍了小鎮，人們經常提起這個感人的故事，並以小奇為榮。這個故事也提醒了每個人關愛動物、珍惜生命以及勇於伸出援手的重要性。
小奇的故事將永遠被記住，它以自己的行動證明了即使是小小的貓咪，也能成為真正的英雄。
"""),
      StoryData(
          title: '第三章：貓貓奇妙冒險',
          abstraction: '一隻好奇心旺盛的貓從家裡偷偷出門，它在城市中展開了一場奇妙的冒險，遇到了新朋友、發現了新事物，最後平安歸來。',
          content: 'content'),
      StoryData(
          title: '第四章：貓貓與狗狗的友誼',
          abstraction: '一隻孤獨的貓咪遇到了一隻友善的小狗，他們開始了一段深厚的友誼，一起玩耍、分享秘密，並共同面對生活中的挑戰。',
          content: 'content'),
      StoryData(
          title: '第五章：貓貓音樂會',
          abstraction:
              '一隻對音樂充滿熱愛的貓咪發現了一把神奇的小提琴，它隨著音樂的節奏展開了一場驚險刺激的冒險，並帶來了美妙的音樂。',
          content: 'content'),
      StoryData(
          title: '第六章：貓的假期',
          abstraction:
              '一隻貓咪和它的主人一起度假，他們來到了一個美麗的海邊小鎮，貓咪在海灘上玩耍、嘗試新食物，並與其他度假者成為了朋友。',
          content: 'content'),
    ];

    for (int i = 0; i < level && i < defaultStory.length; i++) {
      defaultStory[i].lock = false;
    }
    return defaultStory;
  }
}

class StoryContentPage extends ConsumerStatefulWidget {
  const StoryContentPage({Key? key, required this.data}) : super(key: key);
  final StoryData data;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _StoryContentPageState();
}

class _StoryContentPageState extends ConsumerState<StoryContentPage> {
  final _scrollCtrl = ScrollController();
  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(widget.data.title),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: SafeArea(
            child: Scrollbar(
                controller: _scrollCtrl,
                child: SingleChildScrollView(
                    controller: _scrollCtrl,
                    child: Center(
                      child: Container(
                          constraints: const BoxConstraints(maxWidth: 650),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10.0, horizontal: 10.0),
                          child: Text(widget.data.content)),
                    )))));
  }
}

class StoryListElement extends StatelessWidget {
  const StoryListElement({Key? key, required this.data}) : super(key: key);
  final StoryData data;
  @override
  Widget build(BuildContext context) {
    return Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        color: data.lock ? Colors.grey[300] : Colors.white,
        child: data.lock
            ? ListTile(
                leading: const Icon(Icons.lock),
                title: Text(data.title,
                    style: const TextStyle(
                        color: Colors.brown, fontWeight: FontWeight.bold)),
              )
            : InkWell(
                borderRadius: BorderRadius.circular(8),
                child: ListTile(
                  leading: const Icon(Icons.import_contacts),
                  title: Text(data.title,
                      style: const TextStyle(
                          color: Colors.brown, fontWeight: FontWeight.bold)),
                ),
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StoryContentPage(data: data)));
                },
              ));
  }
}
