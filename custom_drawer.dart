import 'package:flutter/material.dart';
import 'package:youth_playground/screens/main_screen.dart';

import '../screens/management_screen.dart';

/// 네비게이션 메뉴
class DrawerWidget extends StatefulWidget {
  final DrawerSelectionCallback onCompleteSchedule;
  const DrawerWidget({super.key, required this.onCompleteSchedule});

  _DrawerScreenState createState() => _DrawerScreenState();
}

class _DrawerScreenState extends State<DrawerWidget> {


  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Builder(builder: (BuildContext context) {
        return Column(
            children: [
              const SizedBox(height: 32,), // 상단 여백
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPress: () {},
                onTapDown: (details) {},
                onTap: () async {
                  Navigator.pop(context);
                  var result = await Navigator.of(context).pushNamed('/schedulerequest');
                  if (result != null) {
                    if (result == "from_schedule_request_screen") {
                      widget.onCompleteSchedule("from_schedule_request_screen");
                    }
                  }
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 18.35, bottom: 16.95,left: 20.97,right: 19.22),
                  child: const Row(
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
                  margin: const EdgeInsets.only(left: 13.98, right: 13.98),
                  child: const Divider(
                    height: 0.87,
                    color: Color(0xffebebeb),
                  )),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onLongPress: () {},
                onTapDown: (details) {},
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PasswordDialogScreen(),
                    ),
                  );
                },
                child: Container(
                  alignment: Alignment.centerLeft,
                  margin: const EdgeInsets.only(top: 18.35, bottom: 16.95,left: 20.97,right: 19.22),
                  child: const Row(
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
                  margin: const EdgeInsets.only(left: 13.98, right: 13.98),
                  child: const Divider(
                    height: 0.87,
                    color: Color(0xffebebeb),
                  )),
              // GestureDetector(
              //   behavior: HitTestBehavior.opaque,
              //   onLongPress: () {},
              //   onTapDown: (details) {},
              //   onTap: () {
              //     // todo - 메뉴 클릭에 대한 화면 이동 로직 구현 필요
              //     Navigator.pop(context);
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => MainScreen(),
              //       ),
              //     );
              //   },
              //   child: Container(
              //     alignment: Alignment.centerLeft,
              //     margin: const EdgeInsets.only(top: 18.35, bottom: 16.95,left: 20.97,right: 19.22),
              //     child: const Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(
              //           "만든 사람들",
              //           style: TextStyle(fontSize: 16.6),
              //         ),
              //         Icon(Icons.chevron_right)
              //       ],
              //     ),
              //   ),
              // ),
              // Container(
              //     alignment: Alignment.centerLeft,
              //     margin: const EdgeInsets.only(left: 13.98, right: 13.98),
              //     child: const Divider(
              //       height: 0.87,
              //       color: Color(0xffebebeb),
              //     )),
              // GestureDetector(
              //   behavior: HitTestBehavior.opaque,
              //   onLongPress: () {},
              //   onTapDown: (details) {},
              //   onTap: () {
              //     Navigator.pop(context);
              //     // todo - 메뉴 클릭에 대한 화면 이동 로직 구현 필요
              //     Navigator.push(
              //       context,
              //       MaterialPageRoute(
              //         builder: (context) => MainScreen(),
              //       ),
              //     );
              //   },
              //   child: Container(
              //     alignment: Alignment.centerLeft,
              //     margin: const EdgeInsets.only(top: 18.35, bottom: 16.95,left: 20.97,right: 19.22),
              //     child: const Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(
              //           "놀이터 유틸리티 이용방법",
              //           style: TextStyle(fontSize: 16.6),
              //         ),
              //         Icon(Icons.chevron_right)
              //       ],
              //     ),
              //   ),
              // ),
              // Container(
              //     alignment: Alignment.centerLeft,
              //     margin: const EdgeInsets.only(left: 13.98, right: 13.98),
              //     child: const Divider(
              //       height: 0.87,
              //       color: Color(0xffebebeb),
              //     )),
              // GestureDetector(
              //   behavior: HitTestBehavior.opaque,
              //   onLongPress: () {},
              //   onTapDown: (details) {},
              //   onTap: () {
              //     Navigator.pop(context);
              //     // 화면 전환 -> 구독한 알림 설정 화면으로 이동 !
              //     Navigator.pushNamed(context, '/notificationsetting');
              //   },
              //   child: Container(
              //     alignment: Alignment.centerLeft,
              //     margin: EdgeInsets.only(top: 18.35, bottom: 16.95,left: 20.97,right: 19.22),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text(
              //           "구독한 알림 설정",
              //           style: TextStyle(fontSize: 16.6),
              //         ),
              //         Icon(Icons.chevron_right)
              //       ],
              //     ),
              //   ),
              // ),
              // Container(
              //     alignment: Alignment.centerLeft,
              //     margin: const EdgeInsets.only(left: 13.98, right: 13.98),
              //     child: const Divider(
              //       height: 0.87,
              //       color: Color(0xffebebeb),
              //     )),
            ]);
      }),
    );
  }
}
