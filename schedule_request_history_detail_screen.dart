import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/calendar_event_info.dart';
import '../widgets/appbar.dart';

/// 일정 요청 내역 상세 (관리자)
class ScheduleRequestHistoryDetailScreen extends StatefulWidget {
  CalendarEventInfo? calendarEventInfo; // 메인 화면에서 넘겨받은 클릭된 일정 데이터
  ScheduleRequestHistoryDetailScreen(
      {super.key, required this.calendarEventInfo});

  @override
  _ScheduleRequestHistoryDetailScreenState createState() =>
      _ScheduleRequestHistoryDetailScreenState();
}

class _ScheduleRequestHistoryDetailScreenState extends State<ScheduleRequestHistoryDetailScreen> {
  int _currentImageIndex = 0; // 이미지 indicator 처리를 위한 현재 보고 있는 이미지 index
  final CarouselController _controller = CarouselController();
  bool isNothingImage = false;
  late DatabaseReference databaseRef; // firebase database reference

  @override
  void initState() {
    super.initState();

    databaseRef = FirebaseDatabase.instance.ref();

    // 게시글 이미지 주소 데이터에 nothing이 포함 되어있으면 이미지 미포함 상태이기에 No Image UI 처리
    if (widget.calendarEventInfo!.images[0].contains("nothing")) {
      setState(() {
        isNothingImage = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        appBarText: '신청 내용',
        appBarFontSize: 17.5,
        isFontBold: false,
        isCenterText: true,
        isCanBack: true,
      ),
      body: Stack(
        children: [
          Container(
            color: Colors.deepOrange,
          ),
          Container(
            margin: EdgeInsets.only(left: 20, top: 21, right: 20, bottom: 10.5),
            padding: EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  offset: Offset(0, 2),
                  blurRadius: 6.0,
                  spreadRadius: 0.0,
                ),
              ],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(0),
                topRight: Radius.circular(20.0),
                bottomLeft: Radius.circular(20.0),
                bottomRight: Radius.circular(20.0),
              ),
            ),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.calendarEventInfo!.title,
                          style: TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 14, bottom: 11),
                          child: Divider(
                            height: 0.87,
                            color: Color(0xffebebeb),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 5.0),
                          child: Row(
                            children: [
                              Text(
                                "일시",
                                style: TextStyle(
                                    color: Color(0xffff16623),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                child: Text(
                                  DateFormat("yyyy. MM. dd E요일 HH시 mm분", "ko")
                                      .format(
                                          DateTime.fromMillisecondsSinceEpoch(
                                              widget.calendarEventInfo!
                                                  .eventTime)),
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 15,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(bottom: 5.0),
                          child: Row(
                            children: [
                              Text(
                                "장소",
                                style: TextStyle(
                                    color: Color(0xffff16623),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                child: Text(
                                  widget.calendarEventInfo!.location,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          child: Row(
                            children: [
                              const Text(
                                "주최",
                                style: TextStyle(
                                    color: Color(0xffff16623),
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                margin: EdgeInsets.only(left: 8),
                                child: Text(
                                  widget.calendarEventInfo!.host,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(top: 25),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                  color: Colors.white,
                                  child: Stack(
                                    alignment:
                                        AlignmentDirectional.bottomCenter,
                                    children: [
                                      CarouselSlider(
                                        options: CarouselOptions(
                                          height: 240.0,
                                          autoPlay: false,
                                          padEnds: false,
                                          onPageChanged: (index, reason) {
                                            setState(() {
                                              _currentImageIndex = index;
                                            });
                                          },
                                          enableInfiniteScroll: false,
                                          viewportFraction: 1,
                                        ),
                                        carouselController: _controller,
                                        items: widget.calendarEventInfo?.images
                                            .map((String image) {
                                          return Builder(
                                            builder: (BuildContext context) {
                                              return Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                                decoration: const BoxDecoration(
                                                  color: Colors.grey,
                                                ),
                                                // no-image 일 상황도 생각하여 위젯 분기처리
                                                child: isNothingImage == false
                                                    ? Image.network(
                                                        image,
                                                        fit: BoxFit.cover,
                                                      )
                                                    : Image.asset(
                                                        "assets/img_no_image.png",
                                                        fit: BoxFit.cover,
                                                      ),
                                              );
                                            },
                                          );
                                        }).toList(),
                                      ),
                                      // 이미지 슬라이더 인디케이터
                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: widget
                                            .calendarEventInfo!.images
                                            .asMap()
                                            .entries
                                            .map((entry) {
                                          return Container(
                                            width: 12.0,
                                            height: 12.0,
                                            margin: const EdgeInsets.fromLTRB(
                                                4, 20, 4, 10),
                                            decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: const Color(0xFFffcd21)
                                                    .withOpacity(
                                                        _currentImageIndex ==
                                                                entry.key
                                                            ? 0.9
                                                            : 0.4)),
                                          );
                                        }).toList(),
                                      ),
                                    ],
                                  )),
                              const Text(
                                "행사 내용",
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold),
                              ),
                              Container(
                                  margin: EdgeInsets.only(top: 8),
                                  child:
                                      Text(widget.calendarEventInfo!.content)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(
                  thickness: 0.87,
                  color: Color(0xffF16623),
                ),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          // 반려 버튼 터치 이벤트 처리

                          // 게시글 권한 변경 후 현재 화면 빠져나가기
                          databaseRef
                              .child('CalendarEventInfo')
                              .child(widget.calendarEventInfo!.createdAt
                                  .toString())
                              .child('isGranted')
                              .set(0).whenComplete(() => Navigator.pop(context, -1));
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 10),
                          height: 50,
                          color: Colors.white,
                          child: const Center(
                            child: Text(
                              '반      려',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                        height: 50,
                        child: VerticalDivider(
                          thickness: 0.87,
                          color: Color(0xffF16623),
                        )),
                    Expanded(
                      flex: 1,
                      child: GestureDetector(
                        onTap: () {
                          // 반려 버튼 터치 이벤트 처리

                          // 게시글 권한 변경 후 현재 화면 빠져나가기
                          databaseRef
                              .child('CalendarEventInfo')
                              .child(widget.calendarEventInfo!.createdAt
                                  .toString())
                              .child('isGranted')
                              .set(1).whenComplete(() => Navigator.pop(context, 1));

                        },
                        child: Container(
                          margin: const EdgeInsets.only(left: 10),
                          height: 50,
                          color: Colors.white,
                          child: const Center(
                            child: Text(
                              '수      락',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
