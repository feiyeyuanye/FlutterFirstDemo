import 'package:flutter/material.dart';
import 'package:english_words/english_words.dart';

/// 符号(=>)， 它是只有一行代码的函数和方法的简写形式。
void main() => runApp(new MyApp());

/// MyApp 继承了 StatelessWidget ,使得它自己成为了一个小组件，
/// Stateless 组件是不可变的，这意味着它们的属性不能改变——所有的值都是final的。
/// 在Flutter中， 几乎所有东西都是一个组件，包括对其，填充和布局。
class MyApp extends StatelessWidget {
  // 组件的主要共组是提供一个 build() 方法，
  // 这个方法描述了如何显示其他小组件
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Startup Name Generator',
      // 更改主题
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      home: new Randoms(),
    );
  }
}

/// Stateful 组件可以保存状态，它在其生命周期内可以改变状态，实现了 stateful 的组件至少需要两个类：
/// StatefulWidget 与 State 。
/// StatefulWidget 本身是不可变的，但是 State 是可变的，并且存在生命周期。
class Randoms extends StatefulWidget{
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return new RandomsState();
  }
}

/// Randoms 的状态类，这里实现了大部分的代码
/// 在 Dart 中，以下划线开头的变量是私有的
class RandomsState extends State<Randoms> {

  // 保存了列表显示的单词对
  final _listItem = <WordPair>[];
  // 收藏的单词对，Set 要优于 List，因为Set不允许出现重复元素。
  final _listSave = new Set<WordPair>();
  // 字体大小
  final _listFont = const TextStyle(fontSize: 18.0);

  /// 显示单词对列表的 ListView 。
  Widget _buildSuggestions(){
    return new ListView.builder(
        padding:  const EdgeInsets.all(16.0),
        // itemBuilder 在每次生成一个单词对时被回调
        // 每一行都是用 ListTile 代表
        // 对于偶数行，这个回调函数都添加一个 ListTile 组件来保存单词对
        // 对于奇数行，这个回调函数会添加一个 Divider 组件来在视觉上分割单词对。
        // 注意，在小设备上看到分割物可能会非常困难

        // 属性 itemBuilder , 这个属性需要一个匿名函数作为其回调。
        // 这个匿名函数有两个参数--- BuildContext 和迭代行数 i ,迭代从 0 开始。
        // 每次对一个单词对执行回调后都会加一。
        // 这种模式允许单词对列表随着用户滚动屏幕而增长。
        itemBuilder: (context,i){
          //  在 ListView 组件的每行之前，先添加一个像素高度的分割。
          if (i.isOdd) return new Divider();

          // 这个"i ~/ 2"的表达式将i 除以 2，然后会返回一个整数结果。
          // 例： 1, 2, 3, 4, 5 会变成 0, 1, 1, 2, 2。
          // 这个表达式会计算 ListView 中单词对的真实数量
          final index = i ~/ 2;

          // 如果到达了单词对列表的结尾处...
          if (index >= _listItem.length) {

            // ...然后生成10个单词对到建议的名称列表中。
            _listItem.addAll(generateWordPairs().take(10));
          }
          // 在每次生成单词对后，_buildSuggestions 会调用 _buildRow。
          // 这个函数使用 ListTile 组件显示每一个新的单词对，这使得每一行更加好看。
          return _buildRow(_listItem[index]);
        }
    );
  }

  Widget _buildRow(WordPair pair) {
//    alreadySaved 字段用来判断单词对是否已经加入了收藏夹中。
    final alreadySaved = _listSave.contains(pair);
    return new ListTile(
      title: new Text(
        pair.asPascalCase,
        style: _listFont,
      ),
      trailing: new Icon(
        alreadySaved ? Icons.favorite : Icons.favorite_border,
        color: alreadySaved ? Colors.red : null,
      ),
      // 当图标被点击后，会调用 setState() 回调函数来通知框架状态已经改变了。
      // 注:在Flutter的响应式框架中，调用setState() 会触发对 State 对象的 build() 方法的调用，从而导致UI的更新。
      onTap: () {
        setState(() {
          if (alreadySaved) {
            _listSave.remove(pair);
          } else {
            _listSave.add(pair);
          }
        });
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold (
      appBar: new AppBar(
        title: new Text('Startup Name Generator'),
        // 导航到新窗口
        // 导航器管理包含 route 的堆栈。
        // 添加一个 route 在导航栈上，新界面将通过该 route 进入。
        // 从导航栈中弹出一条 route，将回到原来的界面。
        actions: <Widget>[
          new IconButton(icon: new Icon(Icons.list), onPressed: _pushSaved),
        ],
      ),
      body: _buildSuggestions(),
    );
  }

  /// 收藏页
  void _pushSaved() {
    Navigator.of(context).push(
      new MaterialPageRoute(
        // 添加 MaterialPageRoute 和它的 builder 属性，然后添加生成ListTile行的代码。
        builder: (context) {
          final tiles = _listSave.map((pair) {
              return new ListTile(
                title: new Text(
                  pair.asPascalCase,
                  style: _listFont,
                ),
              );
            },
          );
          // ListTile 的 divideTiles() 方法在每行之间添加了一个水平的间距。
          // divided 变量保存了最后一行，最后由 toList() 函数转换为列表:
          final divided = ListTile.divideTiles(
            context: context,
            tiles: tiles,
          ).toList();
          // builder 返回一个 Scaffold 组件，为包含一个新界面的顶栏，名为 “Saved Suggestions.”。
          // 新界面的 body 属性是包含若干 ListTiles 的 ListView ，每一行使用分割线分割。
          return new Scaffold(
            appBar: new AppBar(
              title: new Text('Saved Suggestions'),
            ),
            body: new ListView(children: divided),
          );
        },
      ),
    );
  }
}