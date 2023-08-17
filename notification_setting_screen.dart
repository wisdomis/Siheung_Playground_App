import 'package:flutter/material.dart';
import 'package:youth_playground/common/util/database_util.dart';
import 'package:youth_playground/common/util/notification_util.dart';
import 'package:youth_playground/models/subscription_info.dart';

import '../common/define.dart';
import '../models/calendar_event_info.dart';

/// 알림 설정 화면
class NotificationSettingScreen extends StatefulWidget {
  CalendarEventInfo? calendarEventInfo; // 메인 화면 에서 넘겨 받은 클릭된 일정 데이터
  NotificationSettingScreen({super.key, required this.calendarEventInfo});
  @override
  _NotificationSettingScreenState createState() => _NotificationSettingScreenState();
}

class _NotificationSettingScreenState extends State<NotificationSettingScreen> {
  DatabaseHelper dbHelper = DatabaseHelper(); // 내부 데이터베이스 객체
  List<bool> lstSwitchBoolArray = [
    false,
    false,
    false,
    false
  ]; // switch checked 값 배열

  ValueNotifier<SubscriptionEventInfo?> subscriptionEventInfo = ValueNotifier(
      null); // 구독 알림설정 객체

  @override
  void initState() {
    super.initState();

    // 내부 db를 조회 하여 이전에 저장된 스위치 상태 값을 가지고 온다
    getSubscriptionStatusArray();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 바 영역
      appBar: AppBar(
        elevation: 0,
        shape: const Border(
          bottom: BorderSide(
            color: Color(0xffEBEBEB),
            width: 0.87,
          ),
        ),
        centerTitle: true,
        title: const Text(
          "알림",
          style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 17.48,
              color: Colors.black),
        ),
        leading: IconButton(
            onPressed: () {
              // 버튼 클릭 했을 때
              Navigator.pop(context, "detail_screen");
            },
            color: Colors.black,
            icon: const Icon(
              Icons.arrow_back_ios_new,
              size: 20,
            )),
        backgroundColor: Colors.white,
      ),
      // 콘텐츠 영역 children (복수개의 위젯 배열로 넣어라) , child (1개 위젯)
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(scrollDirection: Axis.vertical, child: Column(
          children: [
            Container(
              height: 53.3,
              margin: const EdgeInsets.only(left: 20.97, right: 27.96),
              child: Row(
                children: [
                  const Text(
                    "30분전",
                    style: TextStyle(fontSize: 16.6),
                  ),
                  const Spacer(), // 가중치 (비율) 를 부여하여 좌우 위젯을 밀쳐냄 !!
                  MySwitchButton(
                    Const.switchTimeMinute30,
                    lstSwitchBoolArray[0],
                    subscriptionEventInfo,
                    widget.calendarEventInfo!,),
                ],
              ),
            ),
            // 구분자
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 13.98),
                child: const Divider(
                  thickness: 1,
                  color: Color(0xffEBEBEB),
                )),
            Container(
              height: 53.3,
              margin: const EdgeInsets.only(left: 20.97, right: 27.96),
              child: Row(
                children: [
                  const Text(
                    "1시간 전",
                    style: TextStyle(fontSize: 16.6),
                  ),
                  const Spacer(), // 가중치 (비율) 를 부여하여 좌우 위젯을 밀쳐냄 !!
                  MySwitchButton(
                    Const.switchTimeHour1,
                    lstSwitchBoolArray[1],
                    subscriptionEventInfo,
                    widget.calendarEventInfo!,),
                ],
              ),
            ),
            // 구분자
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 13.98),
                child: const Divider(
                  thickness: 1,
                  color: Color(0xffEBEBEB),
                )),
            Container(
              height: 53.3,
              margin: const EdgeInsets.only(left: 20.97, right: 27.96),
              child: Row(
                children: [
                  const Text(
                    "1일 전",
                    style: TextStyle(fontSize: 16.6),
                  ),
                  const Spacer(), // 가중치 (비율) 를 부여하여 좌우 위젯을 밀쳐냄 !!
                  MySwitchButton(
                    Const.switchTimeDay1,
                    lstSwitchBoolArray[2],
                    subscriptionEventInfo,
                    widget.calendarEventInfo!,),
                ],
              ),
            ),
            // 구분자
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 13.98),
                child: const Divider(
                  thickness: 1,
                  color: Color(0xffEBEBEB),
                )),
            Container(
              height: 53.3,
              margin: const EdgeInsets.only(left: 20.97, right: 27.96),
              child: Row(
                children: [
                  const Text(
                    "3일 전",
                    style: TextStyle(fontSize: 16.6),
                  ),
                  const Spacer(), // 가중치 (비율) 를 부여하여 좌우 위젯을 밀쳐냄 !!
                  MySwitchButton(
                    Const.switchTimeDay3,
                    lstSwitchBoolArray[3],
                    subscriptionEventInfo,
                    widget.calendarEventInfo!,),
                ],
              ),
            ),
            // 구분자
            Container(
                margin: const EdgeInsets.symmetric(horizontal: 13.98),
                child: const Divider(
                  thickness: 1,
                  color: Color(0xffEBEBEB),
                )),
          ],
        ),),
      ),
    );
  }

  Future<void> getSubscriptionStatusArray() async {
    List<SubscriptionEventInfo> lstSubscription = await dbHelper.getSubscriptionList();

    for (SubscriptionEventInfo eventInfo in lstSubscription) {
      // 구독 정보를 구분 해낼 수 있는 고유 값으로 이벤트 생성 당시 time milliseconds 값을 가지고옴
      if (eventInfo.createdAt == widget.calendarEventInfo!.createdAt) {
        // 이전에 저장된 이력이 있으면 해당 객체를 전역 변수에 담아줌
        subscriptionEventInfo.value = eventInfo;

        // 각 스위치 상태 값에 할당
        lstSwitchBoolArray[0] = eventInfo.isSub30minutes == 0 ? false : true;
        lstSwitchBoolArray[1] = eventInfo.isSub1Hours == 0 ? false : true;
        lstSwitchBoolArray[2] = eventInfo.isSub1Day == 0 ? false : true;
        lstSwitchBoolArray[3] = eventInfo.isSub3Day == 0 ? false : true;
        break;
      }
    }

    setState(() {});
  }
}

class MySwitchButton extends StatefulWidget {
  int currentSwitch = -1; // 외부 위젯을 생성하는 클래스에서 넘겨져 오는 현재 switch enum 값
  bool isSwitchOn = false;
  ValueNotifier<SubscriptionEventInfo?> subscriptionEventInfo;
  CalendarEventInfo calendarEventInfo;

  MySwitchButton(this.currentSwitch,
      this.isSwitchOn,
      this.subscriptionEventInfo,
      this.calendarEventInfo,
      {super.key});

  @override
  _MySwitchButtonState createState() => _MySwitchButtonState();
}

class _MySwitchButtonState extends State<MySwitchButton> {
  DatabaseHelper dbHelper = DatabaseHelper();
  late DateTime before30Minute, before1Hours, before1Day, before3Day;
  late int NOTIFICATION_30_MINUTE, NOTIFICATION_1_HOUR, NOTIFICATION_1_DAY, NOTIFICATION_3_DAY;

  @override
  void initState() {
    super.initState();
    // 스케쥴 알림을 걸기위한 준비 (일정 시간 기준으로 30분전, 1시간전, 1일전, 3일전에 대한 date time 값이 필요 하다)
    before30Minute = DateTime.fromMillisecondsSinceEpoch(widget.calendarEventInfo.eventTime).subtract(const Duration(minutes: 30));
    before1Hours = DateTime.fromMillisecondsSinceEpoch(widget.calendarEventInfo.eventTime).subtract(const Duration(hours: 1));
    before1Day = DateTime.fromMillisecondsSinceEpoch(widget.calendarEventInfo.eventTime).subtract(const Duration(days: 1));
    before3Day = DateTime.fromMillisecondsSinceEpoch(widget.calendarEventInfo.eventTime).subtract(const Duration(days: 3));

    // notification id 들 준비 (모바일에 알림을 설정할 때 꼭 필요한 알림id 값이며, 이미 스케쥴된 알림을 취소할 때도 활용함)
    // 32 bit integer 만 notification id 로 허용이 되기 때문에 나누기 1만 정도 임의로 했음. 특별한 의미를 담는 숫자는 아님
    NOTIFICATION_30_MINUTE = ((widget.calendarEventInfo.createdAt + Const.timeToMinutes30) / 10000).toInt();
    NOTIFICATION_1_HOUR = ((widget.calendarEventInfo.createdAt + Const.timeToHour1) / 10000).toInt();
    NOTIFICATION_1_DAY = ((widget.calendarEventInfo.createdAt + Const.timeToDay1) / 10000).toInt();
    NOTIFICATION_3_DAY = ((widget.calendarEventInfo.createdAt + Const.timeToDay3) / 10000).toInt();
  }

  @override
  Widget build(BuildContext context) {
    return Switch(
      thumbColor: MaterialStateProperty.all(const Color(0xffffb33f)),
      trackColor: MaterialStateProperty.all(const Color(0xffffd99f)),
      value: widget.isSwitchOn,
      onChanged: (bool value) async {
        /// 신규 db 추가 또는 기존 값 update
        if (widget.subscriptionEventInfo.value != null) {
          /// 이전에 설정한 구독 알림 db 값이 있는 경우

          //
          var eventInfo = widget.subscriptionEventInfo.value;
          if (Const.switchTimeMinute30 == widget.currentSwitch) {
            if (value) {
              eventInfo?.isSub30minutes = 1;
              setChangeScheduleNotification(Const.switchTimeMinute30, 1);
            } else {
              eventInfo?.isSub30minutes = 0;
              setChangeScheduleNotification(Const.switchTimeMinute30, 0);
            }
          } else if (Const.switchTimeHour1 == widget.currentSwitch) {
            if (value) {
              eventInfo?.isSub1Hours = 1;
              setChangeScheduleNotification(Const.switchTimeHour1, 1);
            } else {
              eventInfo?.isSub1Hours = 0;
              setChangeScheduleNotification(Const.switchTimeHour1, 0);
            }
          } else if (Const.switchTimeDay1 == widget.currentSwitch) {
            if (value) {
              eventInfo?.isSub1Day = 1;
              setChangeScheduleNotification(Const.switchTimeDay1, 1);
            } else {
              eventInfo?.isSub1Day = 0;
              setChangeScheduleNotification(Const.switchTimeDay1, 0);
            }
          } else if (Const.switchTimeDay3 == widget.currentSwitch) {
            if (value) {
              eventInfo?.isSub3Day = 1;
              setChangeScheduleNotification(Const.switchTimeDay3, 1);
            } else {
              eventInfo?.isSub3Day = 0;
              setChangeScheduleNotification(Const.switchTimeDay3, 0);
            }
          }

          if (eventInfo?.isSub30minutes == 0 && eventInfo?.isSub1Hours == 0 &&
              eventInfo?.isSub1Day == 0 && eventInfo?.isSub3Day == 0) {
            /// switch 조작 값이 전부 off 로 꺼둔 상태 라면 내부 db의 구독 알림을 제거 한다. (remove)

            // db remove
            setSubscriptionIntoDb(widget.subscriptionEventInfo.value, "remove");
            widget.subscriptionEventInfo.value = null;
          } else {
            /// (update)

            // db update
            setSubscriptionIntoDb(widget.subscriptionEventInfo.value, "update");
          }
        } else {
          /// 처음 으로 구독 알림 설정을 하는 경우 (insert)

          // 새로운 구독 알림 설정 정보 생성
          var eventInfo = SubscriptionEventInfo(
              title: widget.calendarEventInfo.title,
              content: widget.calendarEventInfo.content,
              eventTime: widget.calendarEventInfo.eventTime,
              createdAt: widget.calendarEventInfo.createdAt,
              isSub30minutes: widget.currentSwitch == Const.switchTimeMinute30 ? 1 : 0,
              isSub1Hours: widget.currentSwitch == Const.switchTimeHour1 ? 1 : 0,
              isSub1Day: widget.currentSwitch == Const.switchTimeDay1 ? 1 : 0,
              isSub3Day: widget.currentSwitch == Const.switchTimeDay3 ? 1 : 0);

          // 제목 : 청년 캘린더에 구독하셨던 일정이 30분 남았습니다
          // 내용 : 청년 모임 소셜 다이닝 - 시흥청년스테이션

          // 알림 구독 스케쥴 설정
          if (eventInfo.isSub30minutes == 1) {
            setChangeScheduleNotification(Const.switchTimeMinute30, 1);
          } else if (eventInfo.isSub1Hours == 1) {
            setChangeScheduleNotification(Const.switchTimeHour1, 1);
          } else if (eventInfo.isSub1Day == 1) {
            setChangeScheduleNotification(Const.switchTimeDay1, 1);
          } else if (eventInfo.isSub3Day == 1) {
            setChangeScheduleNotification(Const.switchTimeDay3, 1);
          }

          // db insert
          setSubscriptionIntoDb(eventInfo, "insert");
          widget.subscriptionEventInfo.value = eventInfo;
        }

        // switch 변경 값 ui update
        setState(() {
          widget.isSwitchOn = value;
        });
      },
    );
  }

  Future<void> setSubscriptionIntoDb(SubscriptionEventInfo? eventInfo,
      String strCommand) async {
    if (strCommand == "update") {
      print("@@@@@subscription info update@@@@@");
      await dbHelper.updateSubscriptionInfo(eventInfo!.createdAt, eventInfo);
    } else if (strCommand == "insert") {
      print("@@@@@subscription info insert@@@@@");
      await dbHelper.addSubscriptionInfo(eventInfo!);
    } else if (strCommand == "remove") {
      print("@@@@@subscription info remove@@@@@");
      await dbHelper.removeSubscriptionInfo(eventInfo!.createdAt);
    }
  }

  void setChangeScheduleNotification(int switchValueType, int switchClickStatus) {
    switch (switchValueType) {
      case Const.switchTimeMinute30:
        if (switchClickStatus == 1) {
          // on switch
          FlutterLocalNotification.scheduleNotification(
              before30Minute, '청년 캘린더에 구독하셨던 일정이 30분 남았습니다',
              '${widget.calendarEventInfo.title} - ${widget.calendarEventInfo
                  .host}}', NOTIFICATION_30_MINUTE);
        } else {
          // off switch
          FlutterLocalNotification.cancelScheduleNotification(NOTIFICATION_30_MINUTE);
        }
        break;

      case Const.switchTimeHour1:
        if (switchClickStatus == 1) {
          // on switch
          FlutterLocalNotification.scheduleNotification(
              before1Hours, '청년 캘린더에 구독하셨던 일정이 1시간 남았습니다',
              '${widget.calendarEventInfo.title} - ${widget.calendarEventInfo
                  .host}}', NOTIFICATION_1_HOUR);
        } else {
          // off switch
          FlutterLocalNotification.cancelScheduleNotification(NOTIFICATION_1_HOUR);
        }
        break;

      case Const.switchTimeDay1:
        if (switchClickStatus == 1) {
          // on switch
          FlutterLocalNotification.scheduleNotification(
              before1Day, '청년 캘린더에 구독하셨던 일정이 1일 남았습니다',
              '${widget.calendarEventInfo.title} - ${widget.calendarEventInfo
                  .host}}', NOTIFICATION_1_DAY);
        } else {
          // off switch
          FlutterLocalNotification.cancelScheduleNotification(NOTIFICATION_1_DAY);
        }
        break;

      case Const.switchTimeDay3:
        if (switchClickStatus == 1) {
          // on switch
          FlutterLocalNotification.scheduleNotification(
              before3Day, '청년 캘린더에 구독하셨던 일정이 3일 남았습니다',
              '${widget.calendarEventInfo.title} - ${widget.calendarEventInfo
                  .host}}', NOTIFICATION_3_DAY);
        } else {
          // off switch
          FlutterLocalNotification.cancelScheduleNotification(NOTIFICATION_3_DAY);
        }
        break;
    }

  }
}
