import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
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
enum engine {google,duckduckGo,yahoo}
class _MyHomePageState extends State<MyHomePage> {


  var webkey = GlobalKey();
  TextEditingController searchController = TextEditingController();
  InAppWebViewController? webViewController;
  PullToRefreshController? pullToRefreshController;

//var popupMenuItemIndex = 0;
  engine? eng = engine.google;

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<wallProvider>(context,listen: true);
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
          TextFormField(
            controller: searchController,
            onFieldSubmitted: (value) {
              webViewController!.loadUrl(urlRequest: URLRequest(url: WebUri('https://www.google.com/search?q=${searchController.text}')));
            },

          ),
          Expanded(
            child: InAppWebView(
                onLoadStop: (controller,url){
                  pullToRefreshController!.endRefreshing();
                },
                pullToRefreshController:pullToRefreshController ,
                onWebViewCreated: (value){
                  webViewController = value;
                },
                key: webkey,

                // initialUrlRequest: URLRequest(
                //   url:(WebUri('https://duckduckgo.com/')
                      // if(eng == engine.duckduckGo)
                      // {WebUri('https://duckduckgo.com/')}
                      //
                      // else if(eng == engine.duckduckGo)
                      // {WebUri('https://duckduckgo.com/')}
                      //
                      // else()  {WebUri('https://duckduckgo.com/')}



               initialUrlRequest: URLRequest(url: WebUri('https://www.google.com')),
            ),
          ),
          ButtonBar(

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
              IconButton( onPressed: (){webViewController!.reload();}
                  ,icon: Icon(Icons.home_filled,size: 26,)),
              SizedBox(width: 10,),
              IconButton(
                  onPressed: (){
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
