import 'package:flutter/material.dart';
import 'package:youth_playground/screens/main_screen.dart';
/// 설정 화면
class SettingScreen extends StatefulWidget {
  _SettingScreenState createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          color: Colors.black, // 왼쪽 아이콘으로 메뉴 아이콘을 사용
          onPressed: () {
            Navigator.of(context).pop();
            // 왼쪽 아이콘을 클릭했을 때 수행할 동작
          },
        ),
        backgroundColor: Colors.white,
        title: Text(
          "설정",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          GestureDetector(
            onLongPress: () {},
            onTapDown: (details) {},
            onTap: () {
              // todo - 메뉴 클릭에 대한 화면 이동 로직 구현 필요
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(),
                ),
              );
            },
            child: Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 18.35, bottom: 16.95,left: 20.97,right: 19.22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "일정 생성 요청하기",
                    style: TextStyle(fontSize: 16.6),
                  ),
                  Icon(Icons.chevron_right)
                ],
              ),
            ),
          ),
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 13.98, right: 13.98),
              child: Divider(
                height: 0.87,
                color: Color(0xffebebeb),
              )),
          GestureDetector(
            onLongPress: () {},
            onTapDown: (details) {},
            onTap: () {
              // todo - 메뉴 클릭에 대한 화면 이동 로직 구현 필요
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(),
                ),
              );
            },
            child: Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 18.35, bottom: 16.95,left: 20.97,right: 19.22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "관리자 페이지",
                    style: TextStyle(fontSize: 16.6),
                  ),
                  Icon(Icons.chevron_right)
                ],
              ),
            ),
          ),
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 13.98, right: 13.98),
              child: Divider(
                height: 0.87,
                color: Color(0xffebebeb),
              )),
          GestureDetector(
            onLongPress: () {},
            onTapDown: (details) {},
            onTap: () {
              // todo - 메뉴 클릭에 대한 화면 이동 로직 구현 필요
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(),
                ),
              );
            },
            child: Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 18.35, bottom: 16.95,left: 20.97,right: 19.22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "만든 사람들",
                    style: TextStyle(fontSize: 16.6),
                  ),
                  Icon(Icons.chevron_right)
                ],
              ),
            ),
          ),
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 13.98, right: 13.98),
              child: Divider(
                height: 0.87,
                color: Color(0xffebebeb),
              )),
          GestureDetector(
            onLongPress: () {},
            onTapDown: (details) {},
            onTap: () {
              // todo - 메뉴 클릭에 대한 화면 이동 로직 구현 필요
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(),
                ),
              );
            },
            child: Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 18.35, bottom: 16.95,left: 20.97,right: 19.22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "놀이터 유틸리티 이용방법",
                    style: TextStyle(fontSize: 16.6),
                  ),
                  Icon(Icons.chevron_right)
                ],
              ),
            ),
          ),
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 13.98, right: 13.98),
              child: Divider(
                height: 0.87,
                color: Color(0xffebebeb),
              )),
          GestureDetector(
            onLongPress: () {},
            onTapDown: (details) {},
            onTap: () {
              // todo - 메뉴 클릭에 대한 화면 이동 로직 구현 필요
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(),
                ),
              );
            },
            child: Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(top: 18.35, bottom: 16.95,left: 20.97,right: 19.22),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "구독한 알림 설정",
                    style: TextStyle(fontSize: 16.6),
                  ),
                  Icon(Icons.chevron_right)
                ],
              ),
            ),
          ),
          Container(
              alignment: Alignment.centerLeft,
              margin: EdgeInsets.only(left: 13.98, right: 13.98),
              child: Divider(
                height: 0.87,
                color: Color(0xffebebeb),
              )),

        ],
      ),
    );
  }
}
