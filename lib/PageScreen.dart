import 'package:flutter/material.dart';

import 'PageDetail.dart';

class PageScreen extends StatefulWidget {
  const PageScreen({Key? key}) : super(key: key);

  @override
  _PageScreenState createState() => _PageScreenState();
}

class _PageScreenState extends State<PageScreen> {
  int _counter = 0;
  List<Widget> _pages = [];

  void _incrementCounter() {
    setState(() {
      _counter++;
      _pages.add(
        GestureDetector(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => PageDetail(
                  pageNumber: _counter,
                ),
              ),
            );
          },
          child: Container(
            margin: EdgeInsets.all(8.0),
            padding: EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Color(0xFF54BCBD)),
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  spreadRadius: 2,
                  blurRadius: 5,
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(
                  Icons.text_fields,
                  color: Color(0xFF54BCBD),
                ),
                Text(
                  'Page $_counter',
                  style: TextStyle(
                    color: Color(0xFF377F7F),
                    fontSize: 16.0,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF54BCBD),
        automaticallyImplyLeading: false,
        title: const Text(
          'Page Screen',
          style: TextStyle(color: Color(0xFF377F7F)),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ElevatedButton(
              onPressed: _incrementCounter,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF54BCBD),
              ),
              child: const Text('Add Page'),
            ),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              children: _pages,
            ),
          ],
        ),
      ),
    );
  }
}
