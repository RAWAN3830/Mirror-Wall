import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

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
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
enum engine {google,duckduckGo,yahoo}
class _MyHomePageState extends State<MyHomePage> {
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;
  TextEditingController searchController = TextEditingController();
  engine e = engine.google;

  @override
  void initState() {
    // TODO: implement initState
     pullToRefreshController = PullToRefreshController(
      settings: PullToRefreshSettings(
        color: Colors.black,
      ),
      onRefresh: () async {
        if (Platform.isAndroid) {
          webViewController?.reload();
        } else if (Platform.isIOS) {
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: await webViewController?.getUrl()));
        }
      },
    );

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          PopupMenuButton(
            itemBuilder: (context) {

              return [
                PopupMenuItem(
                  onTap: (){},
                  child: Row(children: [
                    Text('Bookmark'),
                    Icon(Icons.bookmark_add)
                  ]),),
                PopupMenuItem(
                  onTap: (){
                    showDialog(
                      context: context, builder: (context) {
                      return AlertDialog(
                        content: Container(
                          height: 300,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15),
                              color: Colors.white,
                              border:Border.all(width: 3,color: Colors.purple)
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 15,),
                              Text('SEARCH ENGINE',style: TextStyle(fontSize: 25,color: Colors.purple),),

                              RadioListTile(
                                  title: Text('Google'),
                                  value:engine.google ,
                                  groupValue: e,
                                  onChanged: (engine? value){
                                    setState(() {
                                      e = value!;
                                    });
                                    Navigator.of(context).pop();
                                    webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri('https://www.google.com/')));


                                  }),
                              RadioListTile(
                                  title: Text('Yahoo'),
                                  value:engine.yahoo ,
                                  groupValue: e,
                                  onChanged: (engine? value){
                                    setState(() {
                                      e = value!;
                                    });
                                    Navigator.of(context).pop();
                                    webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri('https://in.search.yahoo.com/')));

                                  }),
                              RadioListTile(
                                  title: Text('Duck'),
                                  value:engine.duckduckGo ,
                                  groupValue: e,
                                  onChanged: (engine? value){
                                    setState(() {
                                      e = value!;
                                    });
                                    webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri('https://duckduckgo.com/')));
                                    Navigator.of(context).pop();
                                  }),
                            ],
                          ),
                        ),
                      );
                    },);
                  },
                  child: Row(children: [
                    Text('google'),
                    Icon(Icons.open_in_browser_rounded)
                  ]),)
              ];
            },
            onSelected: (value){},)

        ],
        backgroundColor: Colors.blue,

        title: Text('hello'),
      ),
      body: Column(
        children: [
          Expanded(
            child: InAppWebView(
                onLoadStop: (controller, url) {
                  pullToRefreshController!.endRefreshing();
                },
                pullToRefreshController: pullToRefreshController,
                onWebViewCreated: (value) {
                  webViewController = value;
                },
                // onWebViewCreated: (controller) => webViewController = controller,
                initialUrlRequest:
                URLRequest(url: WebUri("https://www.google.com"))),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: TextFormField(
              decoration: InputDecoration(
                  hintText: 'Search',
                  border: OutlineInputBorder(),
                  suffixIcon: IconButton(
                      onPressed: () {
                        webViewController!.loadUrl(
                            urlRequest: URLRequest(
                                url: (e == engine.google)
                                    ? WebUri('https://www.google.com/search?q=${searchController.text}')
                                    :(e == engine.google)?WebUri('https://duckduckgo.com/${searchController.text}')
                                    :WebUri('https://in.search.yahoo.com/search?q=${searchController.text}')));
                      },
                      icon: Icon(Icons.search))),
              controller: searchController,
              onFieldSubmitted: (value) {
                if(e == engine.google){webViewController!.loadUrl(
                    urlRequest: URLRequest(
                        url: WebUri(
                            'https://www.google.com/search?q=${searchController.text}')));}
                else if(e == engine.duckduckGo){
                  webViewController!.loadUrl(
                      urlRequest: URLRequest(
                          url: WebUri('https://duckduckgo.com/${searchController.text}')));
                }
                else if(e == engine.yahoo){
                  webViewController!.loadUrl(
                      urlRequest: URLRequest(
                          url: WebUri(
                              'https://in.search.yahoo.com/?fr2=inr')));
                }
              },
            ),
          ),
          ButtonBar(
            children: [
              IconButton(
                  onPressed: () {
                    webViewController!.getOriginalUrl();
                  },
                  icon: Icon(
                    Icons.home,
                    size: 35,
                  )),
              SizedBox(
                width: 12,
              ),
              IconButton(
                  onPressed: () {},
                  icon: Icon(
                    Icons.bookmark_add_outlined,
                    size: 35,
                  )),
              SizedBox(
                width: 12,
              ),
              IconButton(
                  onPressed: () {
                    webViewController!.goBack();
                  },
                  icon: Icon(
                    Icons.arrow_back_ios,
                    size: 35,
                  )),
              SizedBox(
                width: 12,
              ),
              IconButton(
                  onPressed: () {
                    webViewController!.reload();
                  },
                  icon: Icon(
                    Icons.refresh,
                    size: 35,
                  )),
              SizedBox(
                width: 12,
              ),
              IconButton(
                  onPressed: () {
                    webViewController!.goForward();
                  },
                  icon: Icon(
                    Icons.arrow_forward_ios,
                    size: 35,
                  )),
              SizedBox(
                width: 5,
              ),
            ],
          ),
        ],
      ),
    );
  }
}