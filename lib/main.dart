import 'dart:math';

import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //定義隨機顏色
  var _color = Colors.blue;

  // final boxes = [
  //   Box(Colors.blue[100], 50, 200, UniqueKey()),
  //   Box(Colors.blue[300], 100, 200,  UniqueKey()),
  //   Box(Colors.blue[500], 150, 200,  UniqueKey()),
  //   Box(Colors.blue[700], 200, 200,  UniqueKey()),
  //   Box(Colors.blue[900], 250, 200,  UniqueKey()),
  // ];
  //第六章教學
  // final _colors =
  // List.generate(8, (index) => Colors.blue[(index+1) * 100]);
  var _colors = [];

  // [
  //   Colors.blue[100],
  //   Colors.blue[300],
  //   Colors.blue[500],
  //   Colors.blue[700],
  //   Colors.blue[800],
  // ];

  int _slot;

  //一開始就執行_shuffle, 避免畫面一開始是空的
  initState() {
    super.initState();
    _shuffle();
  }

  //把方塊打亂順序
  _shuffle() {
    _color = Colors.primaries[Random().nextInt(Colors.primaries.length)];
    _colors = List.generate(8, (index) => _color[(index + 1) * 100]);
    setState(() => _colors.shuffle());
  }

  //檢查勝利條件
  _checkWinCondition() {
    print(_colors.map((c) => c.computeLuminance()).toList());
    // _colors[0].computeLuminance();
    var lum = _colors.map((c) => c.computeLuminance()).toList();

    bool success = true;
    for(int i = 0; i<lum.length-1; i++){
      if (lum[i] > lum[i+1]){
        success = false;
        break;
      }
    }
    print(success ?"Win":"");
  }

  final _globalKey = GlobalKey();
  double _offset;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // key: _globalKey,
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: _shuffle,
            icon: Icon(Icons.refresh),
          ),
        ],
      ),

      // Center(
      // 第四篇教學
      // child: ReorderableListView(
      //   scrollDirection: Axis.horizontal,//切換ReorderableListView方向
      //   onReorder: (int oldIndex, int newIndex) {
      //     //當把 box往下拖曳的時候,把newIndex --
      //     if (newIndex > oldIndex) newIndex--;
      //     print("moved $oldIndex to $newIndex");
      //     final box = boxes.removeAt(oldIndex);
      //     boxes.insert(newIndex, box);
      //   },
      //   children: boxes,
      // ),
      // 第五篇教學
      // child: Row(
      //   children: boxes,
      // ),
      // 第六篇教學
      // child:
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: 32),
            Text(
              "Welcome",
              style: TextStyle(fontSize: 32),
            ),
            const SizedBox(height: 32),
            Container(
              width: Box.width - Box.margin * 2,
              height: Box.height - Box.margin * 2,
              decoration: BoxDecoration(
                color: _color[900],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: Icon(
                Icons.lock_outline,
                color: Colors.white,
              ),
            ),
            SizedBox(height: Box.margin * 2),

            //使用Expanded是因為Stack默認是有多少空間就佔據多少空間.
            //透過Expanded讓Stack知道只能佔用Column上面所剩下的空間.
            Expanded(
              child: Listener(
                //用來偵測觸摸或是滑鼠的事件
                onPointerMove: (event) {
                  // print(event);
                  final y = event.position.dy - _offset;
                  // print(y);
                  if (y > (_slot + 1) * Box.height) {
                    //如果超過了範圍就直接return
                    if (_slot == _colors.length - 1) return;
                    setState(() {
                      final c = _colors[_slot];
                      _colors[_slot] = _colors[_slot + 1];
                      _colors[_slot + 1] = c;
                      _slot++;
                    });
                  } else if (y < _slot * Box.height) {
                    if (_slot == 0) return;
                    setState(() {
                      final c = _colors[_slot];
                      _colors[_slot] = _colors[_slot - 1];
                      _colors[_slot - 1] = c;
                      _slot--;
                    });
                  }
                },
                child: SizedBox(
                  //限制任何東西的寬度都可以用SizexBox

                  width: Box.width,
                  child: Stack(
                    key: _globalKey,
                    children: List.generate(_colors.length, (i) {
                      return Box(
                        color: _colors[i],
                        x: 0,
                        y: i * Box.height,
                        onDrag: (Color color) {
                          print("on drag $color");
                          final index = _colors.indexOf(color);
                          final renderBox = (_globalKey.currentContext
                              .findRenderObject() as RenderBox);
                          // final appBarHeight = renderBox.size.height;
                          // _offset = renderBox.size.height;
                          _offset = renderBox.localToGlobal(Offset.zero).dy;
                          print("on drag $index, _offset = $_offset");
                          _slot = index;

                          //測試換位置
                          // Future.delayed(Duration(seconds: 2), (){
                          //   setState(() {
                          //     final c = _colors[2];
                          //     _colors[2] = _colors[3];
                          //     _colors[3] = c;
                          //   });
                          //
                          // });
                        },
                        onEnd: _checkWinCondition,
                        // key: ValueKey(_colors[i]),
                      );
                    }),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      // ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _shuffle,
      //   child: Icon(Icons.refresh),
      // ),
    );
  }
}

class Box extends StatelessWidget {
  static const width = 250.0;
  static const height = 50.0;
  static const margin = 2.0;

  //加上{}變成命名參數
  Box({
    @required this.color,
    @required this.x,
    @required this.y,
    @required this.onDrag,
    @required this.onEnd,
    // Key key,
  }) : super(
          key: ValueKey(color),
        );

  final Color color;
  final double x, y;
  final Function(Color) onDrag;
  final Function() onEnd;

  @override
  Widget build(BuildContext context) {
    final container = Container(
      // margin: EdgeInsets.all(8.0),
      width: width - margin * 2,
      height: height - margin * 2,
      // color: color,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8.0),
      ),
    );

    return AnimatedPositioned(
      duration: Duration(milliseconds: 100),
      left: x,
      top: y,
      child: Draggable(
        //哪一個在被拖曳
        onDragStarted: () => onDrag(color),
        onDragEnd: (_) => onEnd(),
        //因為不在乎細節, 所以給(_)
        child: container,
        feedback: container,
        childWhenDragging: Visibility(
          visible: false,
          child: container,
        ),
      ),
    );
  }
}
