import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: ProductDetailPage(),
    );
  }
}

class ProductDetailPage extends StatefulWidget {
  @override
  _ProductDetailPageState createState() => _ProductDetailPageState();
}

class _ProductDetailPageState extends State<ProductDetailPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();
  // 為每個區塊設置 GlobalKey
  final List<GlobalKey> _keys = List.generate(3, (_) => GlobalKey());
  bool _isProgrammaticTabChange = false;    // 標記是否是程式碼觸發的 Tab 切換
  String _htmlTag = """
        <ul>
          <li>絕美機身設計,放哪都百搭</li>
          <li>多項安全偵測,全面防止夾貓</li>
          <li>智能App連線,輕鬆遠端操控與監測</li>
          <li>獨家自動物理封袋技術,異味細菌不擴散</li>
        </ul>
        <img src="https://pgw.udn.com.tw/gw/photo.php?u=https://uc.udn.com.tw/photo/2025/07/17/realtime/32606375.jpg&s=Y&x=0&y=0&sw=3000&sh=2000&h=300&w=400" />
        <img src="https://pgw.udn.com.tw/gw/photo.php?u=https://uc.udn.com.tw/photo/2025/07/19/2/32630971.jpg&s=Y&x=0&y=0&sw=3000&sh=2000&h=300&w=400" />
        <img src="https://pgw.udn.com.tw/gw/photo.php?u=https://uc.udn.com.tw/photo/2025/07/17/realtime/32606289.jpg&s=Y&x=0&y=0&sw=3535&sh=2357&h=300&w=400" />
        <p class="fancy">Here's a fancy &lt;p&gt; element!</p>
        """;

  // 滾動到指定區塊
  void _scrollToSection(int index) {
    GlobalKey targetKey = _keys[index];

    final ctx = targetKey.currentContext;
    if (ctx != null) {
      final box = ctx.findRenderObject() as RenderBox;
      // 目標相對螢幕的座標
      final targetPosition = box.localToGlobal(Offset.zero);
      // SliverAppBar 高度（或用 kToolbarHeight）
      const appBarHeight = kToolbarHeight;

      // 算出要滾動的距離：目前的 offset + (目標座標 - appBar高度 - safety area top padding)
      final offset = _scrollController.offset + targetPosition.dy - appBarHeight - MediaQuery.of(context).padding.top + 10;

      _isProgrammaticTabChange = true;   // 設置標記為程式碼觸發的 Tab 切換
      _scrollController.animateTo(
        offset,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      ).then((_) {
        _isProgrammaticTabChange = false;     // 解除標記為程式碼觸發的 Tab 切換
      });;
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToSection(index));
    }
  }

  // 監聽滾動事件
  void _scrollListener() {
    if (_isProgrammaticTabChange) return;
    const appBarHeight = kToolbarHeight;
    for (int i = _keys.length - 1; i >= 0; i--) {
      final ctx = _keys[i].currentContext;
      if (ctx != null) {
        final box = ctx.findRenderObject() as RenderBox;
        final targetPosition = box.localToGlobal(Offset.zero);
        // SliverAppBar 高度（或用 kToolbarHeight）
        double offset = targetPosition.dy - appBarHeight - MediaQuery.of(context).padding.top;
        if (offset <= 0) {
          // 如果當前滾動位置在目標區塊範圍內，則切換 Tab
          if (_tabController.index != i) {
            _isProgrammaticTabChange = true;    // 設置標記為程式碼觸發的 Tab 切換
            _tabController.index = i;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _isProgrammaticTabChange = false;     // 解除標記為程式碼觸發的 Tab 切換
            });
          }
          break;
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    // 監聽 Tab 切換事件
    _tabController.addListener(() {
      if (_isProgrammaticTabChange) return;    // 如果是程式碼觸發的 Tab 切換，則不處理，避免重複觸發
      if (_tabController.indexIsChanging) return; // 避免重複觸發
      _scrollToSection(_tabController.index);
    });
    // 監聽 scroll view 滑動事件
    _scrollController.addListener(_scrollListener);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // 商品 Banner
            SliverToBoxAdapter(
              child: Container(
                height: 200,
                color: Colors.blue[200],
                child: Center(child: Text('商品 Banner', style: TextStyle(fontSize: 24, color: Colors.white))),
              ),
            ),
            // 固定置頂的 SliverAppBar
            SliverAppBar(
              backgroundColor: Colors.white,
              pinned: true, // 固定在頂部
              title: TabBar(
                controller: _tabController,
                tabs: [
                  Tab(text: '商品名稱'),
                  Tab(text: '商品詳情'),
                  Tab(text: '運送方式'),
                ],
              ),
            ),
            // 內容區域
            SliverToBoxAdapter(
              child: Column(
                children: [
                  // 商品名稱區塊
                  Container(
                    key: _keys[0],
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('商品名稱', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        for (int i = 0; i < 1; i++)
                          Container(
                            height: 200,
                            color: Colors.green[100],
                            child: Center(child: Text('商品名稱內容')),
                          ),
                      ],
                    ),
                  ),
                  // 商品詳情區塊
                  Container(
                    key: _keys[1],
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('商品詳情', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Html(
                          data: _htmlTag,
                          extensions: [
                            TagExtension(
                              tagsToExtend: {"flutter"},
                              child: const FlutterLogo(),
                            ),
                            OnImageTapExtension(
                              onImageTap: (src, imgAttributes, element) {
                                print(src);
                              },
                            ),
                          ],
                          style: {
                            "p.fancy": Style(
                              textAlign: TextAlign.center,
                              padding: HtmlPaddings.all(16),
                              backgroundColor: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          },
                        ),
                      ],
                    ),
                  ),
                  // 運送方式區塊
                  Container(
                    key: _keys[2],
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('運送方式', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        for (int i = 0; i < 4; i++)
                          Container(
                            height: 200,
                            color: Colors.red[100],
                            child: Center(child: Text('運送方式內容')),
                          ),
                      ],
                    ),
                  ),
                ],
              )
            ),
          ],
        ),
      ),
    );
  }
}
