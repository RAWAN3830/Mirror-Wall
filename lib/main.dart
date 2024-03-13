import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:mirror_wall/modelclass.dart';
import 'package:mirror_wall/provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MultiProvider(
      providers: [ChangeNotifierProvider(create: (context)=>wallProvider())],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Flutter Demo',
        theme: ThemeData(

          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        home: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}
enum engine {google,duckduckGo,yahoo,bing}
class _MyHomePageState extends State<MyHomePage> {


  var webkey = GlobalKey();
  TextEditingController searchController = TextEditingController();
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;

//var popupMenuItemIndex = 0;
  engine? eng = engine.google;
  int? index = 0;
  @override
  void initState() {
    final fprovider = Provider.of<wallProvider>(context, listen: false);

    super.initState();
    fprovider.initConnectivity();

    fprovider.connectivitySubscription = fprovider
        .connectivity.onConnectivityChanged
        .listen(fprovider.updateConnectionStatus);

    pullToRefreshController = PullToRefreshController(
        options: PullToRefreshOptions(
          color: Color(0xff6054c1),
        ),
        onRefresh: () async {
          await webViewController!.reload();
        });
  }

  @override
  void dispose() {
    final providerVar = Provider.of<wallProvider>(context, listen: false);

    providerVar.connectivitySubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<wallProvider>(context,listen: true);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        actions: [
          PopupMenuButton(
            position: PopupMenuPosition.under,
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  onTap: (){
                    showModalBottomSheet(
                        context: context,
                        builder: (context) {
                          return    provider.modellist.isNotEmpty ?Container(
                            child: ListView.separated(
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    onTap: (){
                                      setState(() {
                                        webViewController!.loadUrl(urlRequest: URLRequest(url:WebUri('${provider.modellist[index].siteName}')));

                                      });
                                      Navigator.of(context).pop();
                                    },
                                    title: Text("${provider.modellist[index].siteName}",style: TextStyle(fontWeight:FontWeight.w700),),
                                    subtitle: Text("${provider.modellist[index].url}"),
                                    trailing: IconButton(
                                      onPressed: (){
                                        provider.deletebookmark(index);
                                      },
                                      icon: Icon(Icons.close),),

                                  );
                                },
                                separatorBuilder:(context, index) {
                                  return SizedBox(height: 10,);
                                },
                                itemCount: provider.modellist.length),
                          ) :
                              Center(child: Text('No BookMark here.......',style: TextStyle(fontSize: 22),));
                        },);
                  },
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
                              border:Border.all(width: 1,)
                          ),
                          child: Column(
                            children: [
                              SizedBox(height: 15,),
                              Text('SEARCH ENGINE',style: TextStyle(fontSize: 25),),
                              RadioListTile(
                                  title: Text('Google'),
                                  value:engine.google ,
                                  groupValue: eng,
                                  onChanged: (engine? value){
                                    setState(() {
                                      eng = value;
                                    });
                                    Navigator.of(context).pop();
                                    webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri('https://www.google.com/')));
                                  }),
                              RadioListTile(
                                  title: Text('Yahoo'),
                                  value:engine.yahoo ,
                                  groupValue: eng,
                                  onChanged: (engine? value){
                                    setState(() {
                                      eng = value;
                                    });
                                    Navigator.of(context).pop();
                                    webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri('https://in.search.yahoo.com/')));
                                  }),
                              RadioListTile(
                                  title: Text('DuckDuckGo'),
                                  value:engine.duckduckGo ,
                                  groupValue: eng,
                                  onChanged: (engine? value){
                                    setState(() {
                                      eng = value;
                                    });
                                    webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri('https://duckduckgo.com/')));
                                    Navigator.of(context).pop();
                                  }),
                              RadioListTile(
                                  title: Text('Bing'),
                                  value:engine.bing ,
                                  groupValue: eng,
                                  onChanged: (engine? value){
                                    setState(() {
                                      eng = value;
                                    });
                                    webViewController!.loadUrl(urlRequest: URLRequest(
                                        url: WebUri('https://www.bing.com/')));
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
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,

        title: Text('hello'),
      ),

      body: Column(
        children: [

          Expanded(
            child: InAppWebView(
                pullToRefreshController:pullToRefreshController ,
                onLoadStop: (controller,url){
                  pullToRefreshController!.endRefreshing();
                },

                onWebViewCreated: (value){
                  webViewController = value;
                },
                key: webkey,
               initialUrlRequest: URLRequest(url: WebUri('https://www.google.com')),

            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: InputDecoration(
                hintText: 'Search'
              ),
              controller: searchController,
              onFieldSubmitted: (value) {
                webViewController!.loadUrl(urlRequest: URLRequest(url:(eng == engine.google)
                    ? WebUri(
                    'https://www.google.com/search?q=${searchController.text}')
                    : (eng == engine.yahoo)
                    ? WebUri(
                    'https://in.search.yahoo.com/search?q=${searchController.text}')
                    : (eng == engine.bing)
                    ? WebUri(
                    'https://www.bing.com/search?q=${searchController.text}')
                    : WebUri(
                    'https://duckduckgo.com/${searchController.text}')));

                searchController.clear();
                // WebUri('https://www.google.com/search?q=${searchController.text}')));
              },

            ),
          ),

          ButtonBar(
            alignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: (){
                  webViewController!.goBack();
                }, icon: Icon(Icons.arrow_back_ios_new_sharp),),
              SizedBox(width: 10,),
              IconButton(
                  onPressed: (){
                    webViewController!.goForward();
                  }, icon:Icon(Icons.arrow_forward_ios_outlined)),
              SizedBox(width: 10,),

              IconButton( onPressed: (){
                webViewController!.reload();
              },
                  icon: Icon(Icons.refresh,size: 26,)),
              SizedBox(width: 10,),

              IconButton(
                  onPressed: (){
                    (eng == engine.google)?webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri('https://www.google.com/')))
                        :(eng == engine.yahoo)?webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri('https://in.search.yahoo.com/')))
                        : (eng == engine.bing)?webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri('https://www.bing.com/')))
                        :webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri('https://duckduckgo.com/')));
                  }
                  ,icon: Icon(Icons.home_filled,size: 26,)),
              SizedBox(width: 10,),
              IconButton(
                  onPressed: () async {
                    if(webViewController != null){
                      ModelClass Data = ModelClass(
                          siteName: await webViewController!.getTitle(),
                          url: await webViewController!.getUrl());
                      provider.bookmarkAdd(Data);
                    }
                  }
                  ,icon: Icon(Icons.bookmark_add_outlined,size: 26,)),

              SizedBox(width: 10,),


              // ElevatedButton(
              //     onPressed: (){
              //       webViewController!.reload();
              //     }, child: Icon(Icons.bookmark_add_outlined,size: 26,)),

            ],)
        ],
      ),

    );
  }
}
