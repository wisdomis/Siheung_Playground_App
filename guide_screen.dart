import 'package:flutter/material.dart';

/// 가이드 화면 (첫 앱 시작 일 때, 설정 창 내부에서 진입할 때의 2가지 케이스 때 이 화면에 진입할 수 있다)
class GuideScreen extends StatefulWidget{
  _GuideScreenState createState()=> _GuideScreenState();
}
class _GuideScreenState extends State<GuideScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color:Colors.white,
        padding: EdgeInsets.all(10),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('guide screen'),
            ],
          ),
        ),
      ),
    );
  }
}