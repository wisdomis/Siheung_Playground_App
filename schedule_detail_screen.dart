import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:youth_playground/common/util/database_util.dart';
import 'package:youth_playground/models/calendar_event_info.dart';
import 'package:youth_playground/models/subscription_info.dart';

import '../common/define.dart';

///일정 상세 화면
class ScheduleDetailScreen extends StatefulWidget {
  CalendarEventInfo? calendarEventInfo; // 메인 화면에서 넘겨받은 클릭된 일정 데이터
  ScheduleDetailScreen({super.key, required this.calendarEventInfo});
  @override
  _ScheduleDetailScreenState createState() => _ScheduleDetailScreenState();
}

class _ScheduleDetailScreenState extends State<ScheduleDetailScreen> {
  // 전역 변수 (멤버 변수) 들
  int _currentImageIndex = 0; // 이미지 indicator 처리를 위한 현재 보고 있는 이미지 index
  final CarouselController _controller = CarouselController();
  bool isNothingImage = false;
  bool isSubscription = false; // 게시글 구독 여부
  get dataList => null;


  @override
  void initState() {
    super.initState();

    // 게시글 이미지 주소 데이터에 nothing이 포함 되어있으면 이미지 미포함 상태이기에 No Image UI 처리
    if (widget.calendarEventInfo!.images[0].contains("nothing")) {
      setState(() {
        isNothingImage = true;
      });
    }

    // 구독 상태 체크하여 구독 버튼 UI 표시
    setCheckSubscriptionStatus();
  }

  Future<void> setToggleSubscription() async {
    /// 알림 구독 토글 버튼 기능 처리

    // 1. 구독 알림 설정 스위치 화면으로 이동 (start activity for result 같은 처리 형태로 구현)
    var result = await Navigator.pushNamed(context, '/notificationsetting', arguments: widget.calendarEventInfo);
    // 2. 스위치 on 하고 돌아와서 다음 화면에서의 알림 설정 값 확인하여 구독하기 status 완료로 할지 결정하여 위젯 업뎃
    if (result != null) {
      if (result == "detail_screen") {
        print("comeback detail screen @@@@");
        /// 내부 db 조회

        // 알림을 1개라도 1로 활성화를 했다면 구독 중 처리
        setCheckSubscriptionStatus();
      }
    }
  }

  Future<void> setCheckSubscriptionStatus() async {
    /// 게시글이 현재 구독 상태인지 체크 !!

    List<SubscriptionEventInfo> lstSubscription = await DatabaseHelper().getSubscriptionList();
    for (SubscriptionEventInfo subscriptionInfo in lstSubscription) {
      /// 내부 db에서 현재 게시글의 일치하는 구독 알림 정보가 있는지 체크
      if (widget.calendarEventInfo?.createdAt == subscriptionInfo.createdAt &&
          widget.calendarEventInfo?.title == subscriptionInfo.title) {

        /// 한개라도 구독하고 있는지 체크
        if (subscriptionInfo.isSub30minutes == 1 || subscriptionInfo.isSub1Hours == 1 || subscriptionInfo.isSub1Day == 1 || subscriptionInfo.isSub3Day == 1) {
          // 구독 완료 ui 처리
          isSubscription = true;
        }
        break;
      }
      // 이 곳을 탔다는건 구독 알림을 아무것도 설정하지 않았기 떄문에 db 상에도 안 남아있을거라서 false 처리해줘야함.
      isSubscription = false;
    }

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            color: Colors.black, // 왼쪽 아이콘으로 메뉴 아이콘을 사용
            onPressed: () {
              Navigator.of(context).pop();
              // 왼쪽 아이콘을 클릭했을 때 수행할 동작
            },
          ),
          title: Text(
            getCategoryTitle(),
            style: const TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 17.48,
            ),
          ),
          centerTitle: true,
          shape: const Border(
            bottom: BorderSide(
              color: Color(0xffFF8736),
              width: 3.5,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  color: Colors.white,
                  child: Stack(
                    alignment: AlignmentDirectional.bottomCenter,
                    children: [
                      CarouselSlider(
                        options: CarouselOptions(
                          height: 360.0,
                          autoPlay: false,
                          enlargeStrategy: CenterPageEnlargeStrategy.zoom,
                          aspectRatio: 16 / 9,
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
                                width: MediaQuery.of(context).size.width,
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
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: widget.calendarEventInfo!.images
                            .asMap()
                            .entries
                            .map((entry) {
                          return Container(
                            width: 12.0,
                            height: 12.0,
                            margin: const EdgeInsets.fromLTRB(4, 20, 4, 10),
                            decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFffcd21).withOpacity(
                                    _currentImageIndex == entry.key
                                        ? 0.9
                                        : 0.4)),
                          );
                        }).toList(),
                      ),
                    ],
                  )),
              Container(
                margin: const EdgeInsets.only(
                    left: 20.97, top: 23.59, right: 15.11), // 프로그램 명 + 버튼 간격 조절
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      widget.calendarEventInfo!.title,
                      style: const TextStyle(
                          fontSize: 20.97, fontWeight: FontWeight.bold),
                    ),
                    const Spacer(),
                    SubscriptionButton(),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(left: 20.97, top: 18),
                child: Row(
                  children: [
                    const Text(
                      "일시",
                      style: TextStyle(
                          fontSize: 16.6,
                          color: Color(0xffF16623),
                          fontWeight: FontWeight.bold),
                    ),
                    // 166634509735 milliseconds (밀리초) -> 년월일시분초
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: Text(
                        DateFormat("yyyy. MM. dd E요일 HH시 mm분", "ko").format(
                            DateTime.fromMillisecondsSinceEpoch(
                                widget.calendarEventInfo!.eventTime)),
                        style: const TextStyle(
                          fontSize: 16.6,
                        ),
                      ),
                    )
                  ],
                ),
              ), // 일시
              Container(
                margin: const EdgeInsets.only(left: 20.97, top: 8),
                child: Row(
                  children: [
                    const Text(
                      "장소",
                      style: TextStyle(
                          fontSize: 16.6,
                          color: Color(0xffF16623),
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: Text(widget.calendarEventInfo!.location,
                          style: const TextStyle(
                            fontSize: 16.6,
                          )),
                    ),
                  ],
                ),
              ), // 징소
              Container(
                margin: const EdgeInsets.only(left: 20.97, top: 8),
                child: Row(
                  children: [
                    const Text(
                      "주최",
                      style: TextStyle(
                          fontSize: 16.6,
                          color: Color(0xffF16623),
                          fontWeight: FontWeight.bold),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 8),
                      child: Text(widget.calendarEventInfo!.host,
                          style: const TextStyle(
                            fontSize: 16.6,
                          )),
                    ),
                  ],
                ),
              ), // 주최
              Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  child: const Divider(
                    thickness: 0.87,
                    color: Color(0xffEBEBEB),
                  )),
              Container(
                  margin: const EdgeInsets.only(left: 20.97),
                  child: const Text(
                    "행사 내용",
                    style: TextStyle(
                        color: Color(0xff686868),
                        fontWeight: FontWeight.bold,
                        fontSize: 16.6),
                  )),
              Container(
                margin: const EdgeInsets.only(left: 20.97, top: 8, bottom: 32),
                child: Text(
                  widget.calendarEventInfo!.content,
                  style: const TextStyle(fontSize: 16.6),
                ),
              ), // 행사 내용
              //),
            ],
          ),
        ));
  }

  // ====== 함수 정의 구간 ======= //
  String getCategoryTitle() {
    /// 카테고리 제목을 반환 하는 함수
    String categoryTitle = "";
    switch (widget.calendarEventInfo?.category) {
      case Const.categoryProgram:
        categoryTitle = '프로그램';
        break;

      case Const.categorySmallGroup:
        categoryTitle = '소모임';
        break;

      case Const.categoryJob:
        categoryTitle = '취업정보';
        break;

      case Const.categoryFestival:
        categoryTitle = '축제/행사';
        break;
    }
    return categoryTitle;
  }

  Widget SubscriptionButton() {
    /// 구독하기 버튼 & 구독완료 버튼 위젯 or 빈 위젯 리턴하는 메소드

    DateTime nowTime = DateTime.now();
    DateTime eventTime = DateTime.fromMillisecondsSinceEpoch(widget.calendarEventInfo!.eventTime);
    Duration duration = eventTime.difference(nowTime);

    // 기본적으로 구독이 가능한 시간대인지를 체크한다. 현재 앱 시나리오 상
    // 게시글에 대한 알림 구독 가능 시간이 적어도 현재 시간보다 30분 이상인 경우에만 해당된다.
    // 게시글을 작성하는 시간까지 넉넉히 고려하여 40분 이상인 경우에만 알림 설정이 가능하도록 로직을 구현하였다.
    if (duration.inMinutes > 40) {
      if (!isSubscription) {
        return ElevatedButton(
          onPressed: () {
            setToggleSubscription();
          },
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(87.38),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(const Color(0xffefefef)),
            side: MaterialStateProperty.all<BorderSide>(
              const BorderSide(
                color: Colors.black,
                width: 0.87,
              ),
            ),
          ),
          child: const Text(
            "구독하기",
            style: TextStyle(fontSize: 13.11, color: Colors.black),
          ),
        );
      } else {
        return ElevatedButton(
          onPressed: () {
            setToggleSubscription();
          },
          style: ButtonStyle(
            elevation: MaterialStateProperty.all(0),
            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
              RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(87.38),
              ),
            ),
            backgroundColor: MaterialStateProperty.all(Colors.black),
            side: MaterialStateProperty.all<BorderSide>(
              const BorderSide(
                color: Colors.black,
                width: 0.87,
              ),
            ),
          ),
          child: const Text(
            "구독완료",
            style: TextStyle(fontSize: 13.11, color: Colors.white),
          ),
        );
      }
    } else {
      return const SizedBox.shrink();
    }
  }
}
