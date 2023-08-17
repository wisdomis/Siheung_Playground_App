import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:youth_playground/screens/schedule_request_history_screen.dart';


class PasswordDialogScreen extends StatefulWidget {
  @override
  _PasswordDialogScreenState createState() => _PasswordDialogScreenState();
}

class _PasswordDialogScreenState extends State<PasswordDialogScreen> {
  DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
  String? dbPassword;
  TextEditingController _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    databaseRef.child('ManagerPasswordInfo').once().then((event) {
      dbPassword = event.snapshot.value.toString();
    });
  }

  bool checkPassword(String password) {
    return password == dbPassword;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('비밀번호 입력 (관리자 전용)'),
      content: TextField(
        controller: _passwordController,
        obscureText: true,
        decoration: InputDecoration(
          hintText: '비밀번호를 입력하세요',
        ),
      ),
      actions: [
        TextButton(
          child: Text('확인'),
          onPressed: () {
            String password = _passwordController.text;
            bool isPasswordCorrect = checkPassword(password);
            Navigator.pop(context, isPasswordCorrect);


            if (isPasswordCorrect == true) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScheduleRequestHistoryScreen(), // 새로운 페이지로 이동할 위젯
                ),
              );
            } else if (isPasswordCorrect == false) {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('비밀번호 오류'),
                    content: Text('비밀번호가 틀렸습니다.'),
                    actions: [
                      TextButton(
                        child: Text('확인'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                },
              );
            } else {
              print('비밀번호 입력이 취소되었습니다.');
            }
          },
        ),
      ],
    );
  }
}
