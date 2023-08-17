import 'package:flutter/material.dart';

///splash 화면
class SplashScreen extends StatefulWidget{
  _SplashScreenState createState()=> _SplashScreenState();
}
class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2)).then((value) {   // 3초 후 init_screen으로
      Navigator.pushReplacementNamed(context, '/main');
    });
  }

  @override
  Widget build(BuildContext context) {
    //팝업 다이얼로그 형태로 만들겠음.
    return Scaffold(
      body: Column(
        children: [
          const Spacer(),
          Center(
            child: Column(
              children: [
                Image.asset('assets/img_splash_logo.png', width: 198.09, height: 187.87,),
                Container(margin: const EdgeInsets.only(top: 23.13), child: Image.asset('assets/img_splash_text_logo.png')),
              ],
            ),
          ),
          const Spacer(),
          Container(margin: const EdgeInsets.only(bottom: 80.5), child: const Text('Copyright For.B', style: TextStyle(fontSize: 13),))
        ],
      ),
    );
  }
}