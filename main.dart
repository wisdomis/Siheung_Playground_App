import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:timezone/data/latest.dart' as tzl;
import 'package:youth_playground/common/util/notification_util.dart';
import 'package:youth_playground/models/calendar_event_info.dart';
import 'package:youth_playground/screens/guide_screen.dart';
import 'package:youth_playground/screens/main_screen.dart';
import 'package:youth_playground/screens/management_screen.dart';
import 'package:youth_playground/screens/notification_setting_screen.dart';
import 'package:youth_playground/screens/schedule_detail_screen.dart';
import 'package:youth_playground/screens/schedule_request_history_detail_screen.dart';
import 'package:youth_playground/screens/schedule_request_history_screen.dart';
import 'package:youth_playground/screens/schedule_request_screen.dart';
import 'package:youth_playground/screens/setting_screen.dart';
import 'package:youth_playground/screens/splash_screen.dart';
import 'common/util/database_util.dart';
import 'firebase_options.dart';

/// 프로그램의 초기 진입 점
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // import 는 package:intl/date_symbol_data_local.dart

  // timezone 데이터베이스 초기화
  tzl.initializeTimeZones();

  // init local notification and request permission
  FlutterLocalNotification.init();
  FlutterLocalNotification.requestNotificationPermission();

  // init database helper singleton
  DatabaseHelper();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await initializeDateFormatting();
  runApp(const MyApp());
}



class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '시흥 청년 캘린더',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        // if it's a RTL language
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        // include country code too
      ],
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
      routes: {
        '/':(context) => SplashScreen(),                                                   // 시작
        '/main':(context) => MainScreen(),                                                 // 메인 (캘린더)
        '/setting':(context) => SettingScreen(),                                           // 설정
        '/schedulerequest':(context) => ScheduleRequestScreen(),                           // 일정 생성 요청
        '/schedulerequesthistory':(context) => ScheduleRequestHistoryScreen(),             // 일정 요청 내역
        '/guide':(context) => GuideScreen(),                                               // 가이드 화면
        '/management':(context)=>PasswordDialogScreen(),
      },
      // 데이터를 넘겨받는 처리들을 하는 화면은 하단에서 인자를 받아내어 이동 될 화면으로 넘겨줘야한다.
      onGenerateRoute: (settings) {
        if (settings.name == '/scheduledetail') {                                           // 일정 상세 보기
          final CalendarEventInfo eventInfo = settings.arguments as CalendarEventInfo;
          return MaterialPageRoute(builder: (context) {
            return ScheduleDetailScreen(calendarEventInfo: eventInfo,);
          });
        } else if (settings.name == '/schedulerequesthistorydetail') {                      // 일정 요청 내역 (상세)
          final CalendarEventInfo eventInfo = settings.arguments as CalendarEventInfo;
          return MaterialPageRoute(builder: (context) {
            return ScheduleRequestHistoryDetailScreen(calendarEventInfo: eventInfo,);
          });
        } else if (settings.name == '/notificationsetting') {                               // 구독한 알림 설정
          final CalendarEventInfo eventInfo = settings.arguments as CalendarEventInfo;
          return MaterialPageRoute(builder: (context) {
            return NotificationSettingScreen(calendarEventInfo: eventInfo,);
          });
        }
      },
      theme: ThemeData(primarySwatch: Colors.blue,
          appBarTheme: AppBarTheme(
            color: Colors.white,
            systemOverlayStyle: SystemUiOverlayStyle.dark.copyWith(statusBarColor: Colors.white,),
          )
      ),
    );
  }
}