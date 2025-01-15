import 'package:flutter/material.dart';


class PageDetail extends StatelessWidget {
  final int pageNumber;

  const PageDetail({Key? key, required this.pageNumber}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF54BCBD),
        title: Text('Page $pageNumber Detail'),
      ),
      body: Center(
        child: Text('Content for Page $pageNumber'),
      ),
    );
  }
}

