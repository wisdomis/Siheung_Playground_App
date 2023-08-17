import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/calendar_event_info.dart';
import '../widgets/appbar.dart';

/// 일정 요청 내역 (관리자)
class ScheduleRequestHistoryScreen extends StatefulWidget {
  const ScheduleRequestHistoryScreen({super.key});

  @override
  _ScheduleRequestHistoryScreenState createState() =>
      _ScheduleRequestHistoryScreenState();
}

class _ScheduleRequestHistoryScreenState extends State<ScheduleRequestHistoryScreen> {
  bool isButtonClicked = false;
  late DatabaseReference databaseRef;
  List<CalendarEventInfo> lstEventInfo = []; // 일정 데이터의 배열

  @override
  void initState() {
    databaseRef = FirebaseDatabase.instance.ref();
    // 일정 요청 데이터 리스트 가지고 오기!
    getEventListInfo();
  }

  Future<void> getEventListInfo() async {
    if (lstEventInfo.isNotEmpty) {
      lstEventInfo.clear();
    }

    // 일정 요청 데이터를 가져오기 위해 파이어베이스 데이터를 호출함
    databaseRef = FirebaseDatabase.instance.ref();
    final DatabaseReference eventInfoRef = databaseRef.child("CalendarEventInfo");
    DataSnapshot snapshot = await eventInfoRef.get();
    Map<dynamic, dynamic> eventData = snapshot.value as Map<dynamic, dynamic>;

    if (snapshot.value != null) {
      eventData.forEach((key, value) {
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

        // 배열 리스트에 가지고 온 일정 데이터 1개 씩 전역 리스트에 추가
        lstEventInfo.add(eventInfo);
      });
    }

    setState(() {}); // 화면을 업데이트 합니다.
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(
        appBarText: '신청 리스트',
        appBarFontSize: 17.5,
        isFontBold: false,
        isCenterText: true,
        isCanBack: true,
      ),
      body: Container(
        height: double.infinity,
        color: const Color(0xffff16623),
        child: ListView.builder(
          itemCount: lstEventInfo.length,
          scrollDirection: Axis.vertical,
          shrinkWrap: true,
          padding: const EdgeInsets.all(10),
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              child: buildListItem(index),
              onTap: () async {
                moveToHistoryDetailScreen(index);
              },
            );
          },
        ),
      ),
    );
  }

  Widget buildListItem(int index) {
    return Visibility(
        visible: lstEventInfo[index].isGranted != 1,
        // isgranted가 1이 아닐 때만 보이도록 설정

        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 10.5),
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: Offset(0, 5),
                blurRadius: 5.0,
                spreadRadius: 0.0,
              ),
            ],
            borderRadius: BorderRadius.only(
              topRight: Radius.circular(20.0),
              bottomLeft: Radius.circular(20.0),
              bottomRight: Radius.circular(20.0),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lstEventInfo[index].title,
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 11),
              const Divider(height: 0.87, color: Color(0xffebebeb)),
              buildInfoRow(
                  '일시',
                  DateFormat("yyyy. MM. dd E요일 HH시 mm분", 'ko_KR').format(
                      DateTime.fromMillisecondsSinceEpoch(
                          lstEventInfo[index].eventTime))),
              buildInfoRow('장소', lstEventInfo[index].location),
              buildInfoRow('주최', lstEventInfo[index].host),
              buildButton(index),
            ],
          ),
        ));
  }

  Widget buildInfoRow(String label, String value) {
    return Container(
      margin: EdgeInsets.only(bottom: 5.0),
      child: Row(
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Color(0xffff16623),
              fontSize: 15,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget buildButton(index) {
    String buttonText = isButtonClicked ? "응답 완료" : "";

    if (lstEventInfo[index].isGranted == -1) {
      buttonText = "미응답";
    } else if (lstEventInfo[index].isGranted == 0) {
      buttonText = "반려";
    }

    return Container(
      margin: const EdgeInsets.only(top: 16),
      child: ElevatedButton(
        style: ButtonStyle(
          padding: MaterialStateProperty.all<EdgeInsets>(
            const EdgeInsets.all(10.0),
          ),
          side: MaterialStateProperty.all<BorderSide>(
            const BorderSide(
              color: Colors.black,
              width: 1.0,
            ),
          ),
          shape: MaterialStateProperty.all<RoundedRectangleBorder>(
            RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
          ),
          backgroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
        onPressed: null, // 버튼 기능을 없애려면 onPressed에 null을 할당합니다.
        child: Text(
          buttonText,
          style: const TextStyle(color: Colors.black),
        ),
      ),
    );
  }

  Future<void> moveToHistoryDetailScreen(int _index) async {
    // 일정 요청 기록 상세로 이동
    CalendarEventInfo eventInfo = lstEventInfo[_index];

    var result = await Navigator.pushNamed(context,
        '/schedulerequesthistorydetail',
        arguments: eventInfo);

    if (result != null) {
      if (result == 0 || result == 1) {
        print('return to schedule_request_history screen');
        // 상세 화면에서 수락 또는 반려 처리를 하고 돌아왔을 경우를 대비하여 리스트 갱신처리
        getEventListInfo();
      }
    }
  }
}
