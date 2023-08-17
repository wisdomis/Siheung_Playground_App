import 'package:flutter/material.dart';

// 앱에서 공통 적으로 필요한 style이 적용된 AppBar
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String appBarText; // 앱바의 텍스트 값
  final double appBarFontSize; // 앱바의 텍스트 사이즈
  final bool isFontBold; // font bold 처리 여부
  final bool isCenterText; // 앱바 텍스트 가운데 정렬 여부
  final bool isCanBack; // 백 버튼 존재 여부

  const CustomAppBar({
    Key? key,
    required this.appBarText,
    required this.appBarFontSize,
    required this.isFontBold,
    required this.isCenterText,
    required this.isCanBack
  }) : super(key: key);

  @override
  Size get preferredSize => const Size.fromHeight(56.0);

  @override
  Widget build(BuildContext context) {
    return AppBar(
        key: key,
        iconTheme: const IconThemeData(
          color: Colors.black,
        ),
        title: Text(
          appBarText,
          style: TextStyle(
            color: Colors.black,
            fontWeight: getWeight(),
            fontSize: appBarFontSize,
          ),
        ),
        centerTitle: isCenterText,
        titleSpacing: 0.0,
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: true,
        leading: getLeading(context),);
  }

  FontWeight getWeight() {
    if (isFontBold) {
      return FontWeight.bold;
    } else {
      return FontWeight.normal;
    }
  }

  Widget? getLeading(BuildContext _context) {
    if (isCanBack) {
      return IconButton(
          onPressed: () {
            Navigator.of(_context, rootNavigator: true).pop(_context);
          },
          color: Colors.black,
          icon: Icon(Icons.arrow_back)
      );
    } else {
      return null;
    }
  }
}