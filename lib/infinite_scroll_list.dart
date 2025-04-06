import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class InfiniteScrollList extends StatefulWidget {
  const InfiniteScrollList({super.key});

  @override
  State<InfiniteScrollList> createState() => _InfiniteScrollListState();
}

class _InfiniteScrollListState extends State<InfiniteScrollList> {
  int page = 1;
  bool isLoading = false;
  List productData = [];
  bool isMoreData = true;
  final ScrollController _controller = ScrollController();

  Future<void> getProduct({needLoading = true}) async {
    const limit = 25;
    if (needLoading) {
      setState(() {
        isLoading = true;
      });
    }

    final url = Uri.parse(
        'https://jsonplaceholder.typicode.com/posts?_limit=$limit&_page=$page');
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final List newData = json.decode(response.body);
      setState(
        () {
          page++;
          isLoading = false;
          if (newData.length < 25) {
            setState(() {
              isMoreData = false;
            });
          }
          productData.addAll(newData);
        },
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getProduct(needLoading: true);
    _controller.addListener(() {
      if (_controller.position.maxScrollExtent == _controller.offset) {
        getProduct(needLoading: false);
      }
    });
  }

  Future refreshScreen() async {
    setState(() {
      page = 1;
      isLoading = false;
      productData = [];
      isMoreData = true;
      productData.clear();
      getProduct();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: const Color.fromARGB(255, 18, 0, 220),
        title: const Text(
          "Scroll List",
          style: TextStyle(
            color: Colors.white,
          ),
        ),
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : RefreshIndicator(
              onRefresh: refreshScreen,
              child: ListView.builder(
                controller: _controller,
                itemCount: productData.length + 1,
                itemBuilder: (context, index) {
                  if (index < productData.length) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20,vertical: 9),
                      child: Card(
                        color: Colors.white,
                        child: ListTile(
                          title: Text(
                              "${index + 1}. ${productData[index]['title']}",style: TextStyle(fontSize: 14),),
                        ),
                      ),
                    );
                  } else {
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Center(
                        child: isMoreData
                            ? const CircularProgressIndicator()
                            : const Text(
                                "No More Data",
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                      ),
                    );
                  }
                },
              ),
            ),
    );
  }
}
