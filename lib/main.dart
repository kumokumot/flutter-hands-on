import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_hands_on/pages/home.dart';
import 'package:flutter_hands_on/pages/my_page.dart';
import 'package:flutter_hands_on/pages/product_detail.dart';
import 'package:flutter_hands_on/stores/product_list_store.dart';
import 'package:flutter_hands_on/stores/tab_bar_store.dart';
import 'package:provider/provider.dart';

// main()はFlutterアプリケーションのエントリポイントです
// main()の中で、runAppにルートとなるウィジェットを格納して呼ぶ必要があります
void main() async {
  await DotEnv().load('.env');
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => ProductListStore()),
      ChangeNotifierProvider(create: (context) => TabBarStore()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final store = context.read<ProductListStore>();
      if (store.products.isEmpty) {
        store.fetchNextProducts();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      routes: {
        ProductDetail.routeName: (context) => ProductDetail(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final store = context.watch<TabBarStore>();
    final controller = PageController();
    return Scaffold(
      appBar: AppBar(
        title: const Text("SUZURI"),
      ),
      body: PageView(
        children: <Widget>[
          Home(),
          MyPage(),
        ],
        controller: controller,
        onPageChanged: (index) async {
          context.read<TabBarStore>().updateCurrentIndex(index);
          if (controller.hasClients) {
            controller.jumpToPage(index);
          }
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            title: Text("ホーム"),
            icon: Icon(Icons.home),
          ),
          BottomNavigationBarItem(
            title: Text("マイページ"),
            icon: Icon(Icons.my_location),
          ),
        ],
        onTap: (index) async {
          print(index.toString());
          context.read<TabBarStore>().updateCurrentIndex(index);
          if (controller.hasClients) {
            controller.animateToPage(index,
                duration: Duration(milliseconds: 400),
                curve: Curves.easeInOutSine);
          }
        },
        currentIndex: store.currentIndex,
      ),
    );
  }
}
