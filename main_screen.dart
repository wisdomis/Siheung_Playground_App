import 'dart:collection';

import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:youth_playground/models/calendar_event_info.dart';

import '../common/define.dart';
import '../common/util/calendar_util.dart';
import '../widgets/appbar.dart';
import '../widgets/custom_drawer.dart';

typedef DrawerSelectionCallback = void Function(String resultValue);

///메인 화면 (캘린더)
class MainScreen extends StatefulWidget {
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  ValueNotifier<List<CalendarEventInfo>>? _selectedEvents;
  CalendarFormat _calendarFormat = CalendarFormat.month;
  RangeSelectionMode _rangeSelectionMode = RangeSelectionMode
      .toggledOff; // Can be toggled on/off by longpressing a date
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  DateTime? _rangeStart;
  DateTime? _rangeEnd;

  bool isSelectedSmallGroup = true; // 소모임  chip clicked 여부
  bool isSelectedProgram = true; // 프로그램 chip clicked 여부
  bool isSelectedFestival = true; // 축제, 행사 chip clicked 여부
  bool isSelectedJob = true; // 취업정보 chip clicked 여부

  late Map<DateTime, List<CalendarEventInfo>> kEvents;

  var scheduleRequestCallback = Function;

  @override
  void initState() {
    super.initState();

    kEvents = LinkedHashMap<DateTime, List<CalendarEventInfo>>(hashCode: getHashCode);
    getCalendarEventData();

    // todo - [test code 1] notification 발생,
    // FlutterLocalNotification.showNotification("이홍철", "천재");
    // todo - [test code 2] 예약된 시간으로 설정하여 notification 발생,
    //  주의해야 할 사항은 반드시 디바이스 시간보다 미래 시간대여야 스케쥴 등록이 된다.
    // DateTime scheduledTime = DateTime(2023, 8, 12, 15, 47); // case -> 2023년 8월 12일 오전 1시 5분
    // FlutterLocalNotification.scheduleNotification(scheduledTime, "예약된 알림", "도착했다능 !", 0);
  }

  void _onScheduleRequestResult(String resultValue) {
    if (resultValue == "from_schedule_request_screen") {
      showSnackBar(context, "일정 생성 요청 완료!\n관리자 검토 후 연락처로 피드백 드리겠습니다 :)");
    }
  }

  void showSnackBar(context, text) {
    final snackBar = SnackBar(
      content: Text(text),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<void> getCalendarEventData() async {
    final DatabaseReference databaseRef = FirebaseDatabase.instance.ref();
    final DatabaseReference eventInfoRef =
        databaseRef.child("CalendarEventInfo");

    DataSnapshot snapshot = await eventInfoRef.get();
    Map<dynamic, dynamic> eventData = snapshot.value as Map<dynamic, dynamic>;

    if (snapshot.value != null) {
      eventData.forEach((key, value) {
        DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(value['eventTime']);
        List<CalendarEventInfo> eventList = [];

        CalendarEventInfo eventInfo = CalendarEventInfo(
            title: value['title'],
            content: value['content'],
            category: value['category'],
            host: value['host'],
            location: value['location'],
            isGranted: value['isGranted'],
            eventTime: value['eventTime'],
            createdAt: value['createdAt'],
            images: value['images'].cast<String>().toList(),
            contact: value['contact']);

        eventList.add(eventInfo);
        kEvents[dateTime] = eventList;
      });
    }

    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier(_getEventsForDay(_selectedDay!));

    setState(() {}); // 화면을 업데이트 합니다.
  }

  @override
  void dispose() {
    _selectedEvents?.dispose();
    super.dispose();
  }

  List<CalendarEventInfo> _getEventsForDay(DateTime day) {
    List<CalendarEventInfo> events = [];

    kEvents.forEach((key, value) {
      if (isSameDay(key, day)) {
        events.addAll(value);
      }
    });

    return events;
  }

  List<CalendarEventInfo> _getEventsForRange(DateTime start, DateTime end) {
    final days = daysInRange(start, end);

    return [
      for (final d in days) ..._getEventsForDay(d),
    ];
  }

  void _onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    if (!isSameDay(_selectedDay, selectedDay)) {
      setState(() {
        _selectedDay = selectedDay;
        _focusedDay = focusedDay;
        _rangeStart = null; // Important to clean those
        _rangeEnd = null;
        _rangeSelectionMode = RangeSelectionMode.toggledOff;
      });

      _selectedEvents?.value = _getEventsForDay(selectedDay);

      print("selected event size : ${_getEventsForDay(selectedDay).length}");
    }
  }

  void _onRangeSelected(DateTime? start, DateTime? end, DateTime focusedDay) {
    setState(() {
      _selectedDay = null;
      _focusedDay = focusedDay;
      _rangeStart = start;
      _rangeEnd = end;
      _rangeSelectionMode = RangeSelectionMode.toggledOn;
    });

    // `start` or `end` could be null
    if (start != null && end != null) {
      _selectedEvents?.value = _getEventsForRange(start, end);
    } else if (start != null) {
      _selectedEvents?.value = _getEventsForDay(start);
    } else if (end != null) {
      _selectedEvents?.value = _getEventsForDay(end);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // 상단 바
      appBar: CustomAppBar(
        appBarText: DateFormat("yyyy.M").format(_focusedDay),
        appBarFontSize: 26.21,
        isFontBold: true,
        isCenterText: false,
        isCanBack: false,
      ),
      // 몸통
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              Wrap(
                children: [
                  TableCalendar<CalendarEventInfo>(
                    availableGestures: AvailableGestures.horizontalSwipe,
                    rowHeight: 71.65,
                    daysOfWeekHeight: 30,
                    firstDay: kFirstDay,
                    lastDay: kLastDay,
                    focusedDay: _focusedDay,
                    headerVisible: false,
                    headerStyle: HeaderStyle(
                        headerMargin: EdgeInsets.only(top: 57.67, left: 61.17, bottom: 16),
                        formatButtonVisible: false,
                        leftChevronVisible: false,
                        rightChevronVisible: false,
                        titleTextStyle: const TextStyle(
                            fontSize: 26.21, fontWeight: FontWeight.bold),
                        // titleTextFormatter: (date, locale) => DateFormat.yMMMM(locale).format(date)),
                        titleTextFormatter: (date, locale) =>
                            DateFormat("yyyy.M").format(date)),
                    locale: 'ko_KR',
                    selectedDayPredicate: (day) =>
                        isSameDay(_selectedDay, day),
                    calendarFormat: _calendarFormat,
                    // 롱 클릭 시 범위 선택 모드 가능
                    eventLoader: _getEventsForDay,
                    startingDayOfWeek: StartingDayOfWeek.sunday,
                    // 일요일 부터 시작
                    calendarBuilders: CalendarBuilders(
                      markerBuilder: (context, date, events) {
                        if (events.isNotEmpty) {
                          // createdAt (일정 요청시간) 기준으로 내림차순 정렬
                          events.sort((a, b) {
                            return b.createdAt.compareTo(a.createdAt);
                          });

                          // 최대 3개까지만 캘린더 마커에 표시할 것임 !
                          final limitedEvents = events.take(3).toList();

                          return Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final event in limitedEvents) ...[
                                if (event.category == Const.categoryProgram &&
                                        isSelectedProgram || event.category == Const.categoryFestival && isSelectedFestival ||
                                    event.category == Const.categoryJob &&
                                        isSelectedJob || event.category == Const.categorySmallGroup && isSelectedSmallGroup) ...[
                                  Container(
                                    width: double.infinity,
                                    margin: EdgeInsets.only(bottom: 1.75),
                                    height: 13.98,
                                    decoration: BoxDecoration(
                                      color: getCategoryColor(event.category),
                                      borderRadius:
                                          BorderRadius.circular(1.75),
                                    ),
                                    child: Container(
                                      margin: EdgeInsets.symmetric(horizontal: 2.75),
                                      child: Text(
                                        overflow: TextOverflow.ellipsis,
                                        event.title,
                                        style: TextStyle(
                                            fontSize: 9.61,
                                            color: Colors.white
                                        ),
                                      ),
                                    ),
                                  ),
                                ]
                              ],
                            ],
                          );
                        }
                      },
                      todayBuilder: (context, day, focusedDay) {
                        final text = DateFormat.d().format(day);
                        return Container(
                          margin: EdgeInsets.only(top: 2.5, left: 2.5),
                          alignment: Alignment.topLeft,
                          child: Container(
                            decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.15),
                                shape: BoxShape.circle),
                            width: 17.5,
                            height: 17.5,
                            child: Center(
                                child: Text(
                              text,
                              style: TextStyle(fontSize: 12, color: Colors.black),
                                )
                            ),
                          ),
                        );
                      },
                      // 현재 선택된 캘린더 커스텀 UI
                      selectedBuilder: (context, day, focusedDay) {
                        final text = DateFormat.d().format(day);
                        return Container(
                          margin: const EdgeInsets.only(top: 2.5, left: 2.5),
                          alignment: Alignment.topLeft,
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.black, shape: BoxShape.circle),
                            width: 17.5,
                            height: 17.5,
                            child: Center(
                                child: Text(
                              text,
                              style: const TextStyle(
                                  fontSize: 12, color: Colors.white),
                            )),
                          ),
                        );
                      },
                      // 요일 텍스트 커스텀 UI
                      dowBuilder: (context, day) {
                        final text = DateFormat("E", "ko").format(day);
                        if (day.weekday == DateTime.sunday) {
                          return Center(
                            child: Text(
                              text,
                              style: const TextStyle(
                                  color: Colors.redAccent, fontSize: 11.3592),
                            ),
                          );
                        } else if (day.weekday == DateTime.saturday) {
                          return const Center(
                            child: Text(
                              "토",
                              style: TextStyle(
                                  color: Colors.blueAccent,
                                  fontSize: 11.3592),
                            ),
                          );
                        } else {
                          return Center(
                            child: Text(
                              text,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 11.3592),
                            ),
                          );
                        }
                      },
                      // 일반 cell 에 있는 달력일자 커스텀 UI
                      defaultBuilder: (context, day, focusDay) {
                        final text = DateFormat.d().format(day);
                        return Container(
                            margin: const EdgeInsets.only(top: 2.5, left: 2.5),
                            alignment: Alignment.topLeft,
                            child: Text(
                              text,
                              style: const TextStyle(fontSize: 12),
                            ));
                      },
                      // 현재 달이 아닌 이전 달의 일자, 다음 달의 일자 부분 커스텀 UI
                      outsideBuilder: (context, day, focusDay) {
                        final text = DateFormat.d().format(day);
                        return Container(
                            margin: EdgeInsets.only(top: 2.5, left: 2.5),
                            alignment: Alignment.topLeft,
                            child: Text(
                              text,
                              style: const TextStyle(fontSize: 12),
                            )
                        );
                      },
                    ),
                    calendarStyle: const CalendarStyle(
                      defaultTextStyle: TextStyle(fontSize: 12.23),
                      todayTextStyle:
                          TextStyle(color: Colors.white, fontSize: 12.23),
                      selectedTextStyle: TextStyle(fontSize: 12.23),
                      cellAlignment: Alignment.topLeft,
                      tableBorder: TableBorder(
                          horizontalInside:
                              BorderSide(color: Color(0xffEBEBEB))
                      ),
                      outsideDaysVisible: true,
                      weekendTextStyle: TextStyle(
                          color: Colors.redAccent, fontSize: 11.3592),
                    ),
                    onDaySelected: _onDaySelected,
                    onRangeSelected: _onRangeSelected,
                    onFormatChanged: (format) {
                      if (_calendarFormat != format) {
                        setState(() {
                          _calendarFormat = format;
                        });
                      }
                    },
                    onPageChanged: (focusedDay) {
                      setState(() {
                        _focusedDay = focusedDay;
                      });
                    },
                  ),
                  const SizedBox(height: 19.22),
                  Container(
                    margin: const EdgeInsets.only(left: 13.98, top: 12.85, bottom: 12.85),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          margin: const EdgeInsets.only(left: 12),
                          child: Row(
                            children: [
                              Image.asset('assets/img_category.png'),
                              Container(
                                  margin: const EdgeInsets.only(left: 5),
                                  child: const Text(
                                    "분류",
                                    style: TextStyle(
                                        color: Color(0xffF16623),
                                        fontSize: 14.85),
                                  )),
                            ],
                          ),
                        ),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              // 프로그램 필터 토글 버튼
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSelectedProgram = !isSelectedProgram;
                                  });
                                },
                                child: getChipProgram(),
                              ),
                              Container(
                                // 축제, 행사 필터 토글 버튼
                                margin: const EdgeInsets.only(left: 11),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSelectedFestival = !isSelectedFestival;
                                    });
                                  },
                                  child: getChipFestival(),
                                ),
                              ),
                              Container(
                                // 취업정보 필터 토글 버튼
                                margin: const EdgeInsets.only(left: 11),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSelectedJob = !isSelectedJob;
                                    });
                                  },
                                  child: getChipJob(),
                                ),
                              ),
                              Container(
                                // 소모임 필터 토글 버튼
                                margin: const EdgeInsets.only(left: 11),
                                child: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      isSelectedSmallGroup =
                                          !isSelectedSmallGroup;
                                    });
                                  },
                                  child: getChipSmallGroup(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.only(left: 17.48),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          DateFormat(".d").format(_focusedDay),
                          style: const TextStyle(
                              fontSize: 26.21, fontWeight: FontWeight.bold),
                        ),
                        Container(
                            margin: const EdgeInsets.only(left: 7.58),
                            child: Text(
                              DateFormat("E요일", 'ko').format(_focusedDay),
                              style: const TextStyle(
                                  fontSize: 18.35, fontWeight: FontWeight.bold),
                            )),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 3.84,
                  ),
                  _selectedEvents == null ? const SizedBox.shrink() : ValueListenableBuilder<List<CalendarEventInfo>>(
                    valueListenable: _selectedEvents!,
                    builder: (context, value, _) {
                      // 이벤트 존재 시 해당 리스트 뷰 UI 표시
                      return ListView.builder(
                        shrinkWrap: true,
                        // <==== limit height. 리스트뷰 크기 고정
                        primary: false,
                        // <====  disable scrolling. 리스트뷰 내부는 스크롤 안할거임
                        itemCount: value.length,
                        itemBuilder: (context, index) {
                          return Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 12.0, vertical: 17.48),
                              child: GestureDetector(
                                behavior: HitTestBehavior.opaque,
                                child: Row(
                                  children: [
                                    Container(
                                      width: 4.37,
                                      height: 46.31,
                                      decoration: BoxDecoration(
                                        color: getCategoryColor(
                                            value[index].category),
                                        borderRadius:
                                            BorderRadius.circular(12.0),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                          margin: const EdgeInsets.only(left: 12.23),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                value[index].title,
                                                style: const TextStyle(
                                                    fontSize: 15.73,
                                                    overflow: TextOverflow.ellipsis),
                                              ),
                                              Text(
                                                value[index].content,
                                                style: const TextStyle(
                                                    fontSize: 13.98,
                                                    color: Color(0xff808082),
                                                    overflow: TextOverflow
                                                        .ellipsis),
                                              )
                                            ],
                                          )),
                                    ),
                                  ],
                                ),
                                onTap: () {
                                  // 일정 리스트 아이템 클릭 했을 때 실행 ! (클릭된 일정 정보를 넘긴다)
                                  CalendarEventInfo eventInfo = value[index];
                                  Navigator.of(context).pushNamed(
                                      '/scheduledetail',
                                      arguments: eventInfo);
                                },
                              )
                          );
                        },
                      );
                    },
                  ),
                ],
              )
            ],
          ),
        ),
      ),
      // 햄버거 메뉴 슬라이드 영역
      drawer: DrawerWidget(onCompleteSchedule: _onScheduleRequestResult,),
    );
  }

  Color? getCategoryColor(int categoryType) {
    // 리스트 아이템 값의 카테고리에 맞게 컬러를 리턴한다
    if (categoryType == Const.categoryProgram) {
      // 프로그램 타입
      return const Color(0xffFF8736);
    } else if (categoryType == Const.categoryFestival) {
      // 축제 & 행사 타입
      return const Color(0xffF1B71C);
    } else if (categoryType == Const.categoryJob) {
      // 취업정보 타입
      return const Color(0xff5992F6);
    } else if (categoryType == Const.categorySmallGroup) {
      // 소모임 타입
      return const Color(0xff000000);
    } else {
      // 어떠한 카테고리에도 속하지 않으면
      return const Color(0xff000000);
    }
  }

  Chip getChipProgram() {
    // 프로그램 chip group
    if (isSelectedProgram) {
      return const Chip(
        label: Text('#프로그램'),
        labelStyle: TextStyle(
          color: Colors.white,
        ),
        side: BorderSide(color: Color(0xffF16623), width: 1.0),
        labelPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 7),
        backgroundColor: Color(0xffF16623),
      );
    } else {
      return const Chip(
        label: Text('#프로그램'),
        labelStyle: TextStyle(
          color: Color(0xffF16623),
        ),
        side: BorderSide(color: Color(0xffF16623), width: 1.0),
        labelPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 7),
        backgroundColor: Colors.transparent,
      );
    }
  }

  Chip getChipFestival() {
    // 축제,행사 chip group
    if (isSelectedFestival) {
      return const Chip(
        label: Text('#축제/행사'),
        labelStyle: TextStyle(
          color: Colors.white,
        ),
        side: BorderSide(color: Color(0xffF1B71C), width: 1.0),
        labelPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 7),
        backgroundColor: Color(0xffF1B71C),
      );
    } else {
      return const Chip(
        label: Text('#축제/행사'),
        labelStyle: TextStyle(
          color: Color(0xffF1B71C),
        ),
        side: BorderSide(color: Color(0xffF1B71C), width: 1.0),
        labelPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 7),
        backgroundColor: Colors.transparent,
      );
    }
  }

  Chip getChipJob() {
    // 취업정보 chip group
    if (isSelectedJob) {
      return const Chip(
        label: Text('#취업정보'),
        labelStyle: TextStyle(
          color: Colors.white,
        ),
        side: BorderSide(color: Color(0xff5992F6), width: 1.0),
        labelPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 7),
        backgroundColor: Color(0xff5992F6),
      );
    } else {
      return const Chip(
        label: Text('#취업정보'),
        labelStyle: TextStyle(
          color: Colors.black,
        ),
        side: BorderSide(color: Colors.black, width: 1.0),
        labelPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 7),
        backgroundColor: Colors.transparent,
      );
    }
  }

  Chip getChipSmallGroup() {
    // 소모임 chip group
    if (isSelectedSmallGroup) {
      return const Chip(
        label: Text('#소모임'),
        labelStyle: TextStyle(
          color: Colors.white,
        ),
        side: BorderSide(color: Colors.black, width: 1.0),
        labelPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 7),
        backgroundColor: Colors.black,
      );
    } else {
      return const Chip(
        label: Text('#소모임'),
        labelStyle: TextStyle(
          color: Colors.black,
        ),
        side: BorderSide(color: Colors.black, width: 1.0),
        labelPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 7),
        backgroundColor: Colors.transparent,
      );
    }
  }
}
