import 'dart:io';
import 'package:detectable_text_field/detector/sample_regular_expressions.dart';
import 'package:detectable_text_field/widgets/detectable_text_field.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:youth_playground/models/calendar_event_info.dart';

import '../common/define.dart';

/// 일정 요청 화면
class ScheduleRequestScreen extends StatefulWidget {
  const ScheduleRequestScreen({super.key});

  @override
  _ScheduleRequestScreenState createState() => _ScheduleRequestScreenState();
}

class _ScheduleRequestScreenState extends State<ScheduleRequestScreen> {
  String dropdownValue = '카테고리';                                       // 카테고리 드롭다운 메뉴 선택 값
  TextEditingController titleInputController = TextEditingController(); // 제목
  TextEditingController dateInputController = TextEditingController();  // 일시
  TextEditingController placeInputController = TextEditingController(); // 장소
  TextEditingController hostInputController = TextEditingController();  // 주최
  TextEditingController contentInputController = TextEditingController(); // 행사 내용
  TextEditingController contactInputController = TextEditingController(); // 연락처
  DateTime selectedDateTime = DateTime.now(); // date picker + time picker의 선택 값이 합쳐진 년월일시분의 값을 담음
  TimeOfDay initialTime = TimeOfDay.now();// time picker dialog의 초기 시간

  final ImagePicker _picker = ImagePicker(); // 갤러리 진입을 할 때 활용하는 객체
  List<XFile> _imageFileList = []; // 갤러리에서 이미지를 pick 해올 떄의 리스트

  late DatabaseReference databaseRef; // firebase database reference

  double _uploadProgress = 0;         // 이미지 업로드 상태 값
  bool _isUploading = false;          // 이미지 업로드 중인지 여부

  @override
  void initState() {
    super.initState();

    databaseRef = FirebaseDatabase.instance.ref();
  }

  Future pickImages() async {
    // 갤러리에서 이미지를 추출해온다
    final List<XFile> selectedImages = await _picker.pickMultiImage();
    setState(() {
      _imageFileList = selectedImages;
    });
  }

  void removeImage(int index) {
    // 선택된 index의 이미지 리스트를 제거한다
    setState(() {
      _imageFileList.removeAt(index);
    });
  }

  Future<List<String>> uploadImages(String postTitle) async {
    // upload image
    setState(() {
      _isUploading = true;
    });

    List<String> lstImages = [];
    // 이미지를 Firebase storage에 업로드 한다
    for (var imageFile in _imageFileList) {
      String fileName =
          "${postTitle}_${DateTime.now().millisecondsSinceEpoch}"; // 이미지 파일명 규칙 (게시글 제목 + time mills)
      Reference firebaseStorageRef = FirebaseStorage.instance.ref().child('uploads/$fileName');
      UploadTask uploadTask = firebaseStorageRef.putFile(File(imageFile.path));
      uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      TaskSnapshot taskSnapshot = await uploadTask;
      String imageUrl = await taskSnapshot.ref.getDownloadURL();
      lstImages.add(imageUrl);
    }

    setState(() {
      _isUploading = false;
    });

    return lstImages;
  }

  Future<DateTime?> _selectDate(BuildContext context) async {
    // 일정 선택 date picker dialog 띄우기
    final DateTime? picked = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: selectedDateTime,
      // Initially selected date
      firstDate: DateTime(2000),
      // Earliest date user can pick
      lastDate: DateTime(2100), // Latest date user can pick
    );
    if (picked != null && picked != selectedDateTime) {
      return Future.value(picked);
    }
  }

  @override
  void dispose() {
    titleInputController.dispose();
    dateInputController.dispose();
    placeInputController.dispose();
    hostInputController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "일정 생성 요청",
          style: TextStyle(
              fontSize: 17.43,
              fontWeight: FontWeight.bold,
              color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            onPressed: () {
              // 버튼 클릭 했을 때
              Navigator.of(context, rootNavigator: true).pop(context);
            },
            color: Colors.black,
            icon: const Icon(
              Icons.close,
              size: 24,
            )),
        shape: const Border(
          bottom: BorderSide(
            color: Color(0xffEBEBEB),
            width: 0.87,
          ),
        ),
      ),
      body: Stack(children: [
        if (_isUploading) ...[
          Center(
            child: CircularProgressIndicator(
              value: _uploadProgress,
            ),
          ),
        ],
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// 드롭다운 메뉴
              Container(
                color: Colors.black.withOpacity(0.03),
                margin: const EdgeInsets.only(
                    top: 24.41, left: 20, right: 20, bottom: 23.54),
                child: DropdownButtonHideUnderline(
                  child: ButtonTheme(
                    alignedDropdown: true,
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: dropdownValue,
                      style:
                      const TextStyle(color: Colors.black, fontSize: 13.95),
                      onChanged: (String? newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                      iconSize: 0,
                      items: <String>[
                        '카테고리',
                        '프로그램',
                        '축제/행사',
                        '취업정보',
                        '소모임',
                      ].map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Row(
                            children: <Widget>[
                              const Icon(
                                Icons.arrow_drop_down,
                                size: 24,
                              ),
                              Container(
                                  margin: const EdgeInsets.only(left: 10.48),
                                  child: Text(value)),
                            ],
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              /// 입력 필드 (제목)
              Container(
                margin: const EdgeInsets.only(left: 20.64, right: 20.53, top: 20.52),
                child: TextInputCommonField("제목", titleInputController, false),
              ),

              /// 입력 필드 (일시)
              Container(
                margin: const EdgeInsets.only(
                  left: 20.64,
                  right: 20.53,
                  top: 11.34,
                ),
                child: TextInputCommonField("일시", dateInputController, true),
              ),

              /// 입력 필드 (장소)
              Container(
                margin: const EdgeInsets.only(
                  left: 20.64,
                  right: 20.53,
                  top: 11.34,
                ),
                child: TextInputCommonField("장소", placeInputController, false),
              ),

              /// 입력 필드 (주최)
              Container(
                margin: const EdgeInsets.only(
                  left: 20.64,
                  right: 20.53,
                  top: 11.34,
                ),
                child: TextInputCommonField("주최", hostInputController, false),
              ),

              /// 입력 필드 (행사 내용)
              Container(
                margin: const EdgeInsets.symmetric(vertical: 16, horizontal: 20.4),
                child: const Text(
                  '행사 내용',
                  style: TextStyle(color: Color(0xff686868), fontSize: 13.95),
                ),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 20.4),
                child: DetectableTextField(
                  textInputAction: TextInputAction.done,
                  detectionRegExp: urlRegex,
                  decoratedStyle: const TextStyle(
                    fontSize: 16.56,
                    color: Colors.blue,
                  ),
                  basicStyle: const TextStyle(
                    fontSize: 16.56,
                  ),
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.zero,
                          borderSide: BorderSide(color: Color(0xffD4D4D4)))),
                  controller: contentInputController,
                  minLines: 6,
                  maxLength: 1000,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                ),
              ),

              /// 사진
              Container(
                height: 100,
                margin: const EdgeInsets.only(
                  left: 20.4,
                  right: 20.4,
                ),
                child: Row(
                  children: [
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: () {
                        pickImages();
                      },
                      child: Container(
                        width: 70,
                        height: 70,
                        child: Image.asset('assets/img_add_photo.png',width: 70,height: 70,)
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(left: 16),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        itemCount: _imageFileList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Container(
                            alignment: Alignment.center,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            child: Stack(
                              alignment: Alignment.topRight,
                              children: [
                                Image.file(
                                  File(_imageFileList[index].path),
                                  width: 70,
                                  height: 70,
                                  fit: BoxFit.cover,
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // 이미지 제거
                                    removeImage(index);
                                  },
                                  child: const Icon(Icons.close_rounded),
                                )
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),

              /// 입력 필드 (연락처)
              Container(
                margin: const EdgeInsets.only(
                  left: 20.64,
                  right: 20.53,
                ),
                child: TextInputCommonField("연락처", contactInputController, false),
              ),
              Container(
                margin: const EdgeInsets.only(left: 82.57, top: 8),
                child: const Text(
                  '*승인 및 반려 연락을 드립니다.',
                  style: TextStyle(fontSize: 11.33, color: Color(0xff686868)),
                ),
              ),

              /// 제출하기 버튼
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () async {
                  String title = titleInputController.text;
                  String date = dateInputController.text;
                  String place = placeInputController.text;
                  String host = hostInputController.text;
                  String content = contentInputController.text;
                  String contact = contactInputController.text;

                  if (dropdownValue == '카테고리') {
                    showSnackBar(context, '카테고리를 선택해주세요');
                    return;
                  }

                  // check validation (empty value check)
                  if (title.isEmpty ||
                      date.isEmpty ||
                      place.isEmpty ||
                      host.isEmpty ||
                      content.isEmpty ||
                      contact.isEmpty) {
                    showSnackBar(context, '비어있는 입력 값이 존재 합니다');
                    return;
                  }

                  // 이미지 업로드는 사용자 선택사항이기 떄문에 초기 값을 넣어둔다.
                  List<String> images = ['nothing'];
                  // 만약 이미지를 추가 했다면 이미지 먼저 업로드 한다.
                  if (_imageFileList.isNotEmpty) {
                    images.clear(); // 이미지 업로딩 데이터가 존재할 경우엔 초기 값을 제거해준다
                    images = await uploadImages(title);
                  }

                  // 일정 정보 db에 set 하기 위해 인스턴스 생성
                  CalendarEventInfo eventInfo = CalendarEventInfo(
                      title: title,
                      content: content,
                      category: getCategoryIndex(),
                      host: host,
                      location: place,
                      isGranted: -1,
                      eventTime: selectedDateTime.millisecondsSinceEpoch,
                      createdAt: DateTime.now().millisecondsSinceEpoch,
                      images: images,
                      contact: contact);

                  // set database into calendar event info
                  databaseRef.child('CalendarEventInfo').child(eventInfo.createdAt.toString()).set(eventInfo.toMap());

                  if (mounted) {
                    // 뒤로 가기
                    Navigator.pop(context, "from_schedule_request_screen");
                  }
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 43.19),
                  width: double.infinity,
                  height: 73.75,
                  color: Colors.black,
                  alignment: Alignment.center,
                  child: const Text(
                    '제출하기',
                    style: TextStyle(color: Colors.white, fontSize: 19.18),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],)
    );
  }

  void showSnackBar(context, text) {
    final snackBar = SnackBar(
      content: Text(text),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Widget TextInputCommonField(
    String leftTitle,
    TextEditingController controller,
    bool isReadOnly,
  ) {
    // 입력 컨트롤러 공용 위젯
    return Row(
      children: [
        Text(
          leftTitle,
          style: const TextStyle(color: Color(0xff686868), fontSize: 13.95),
        ),
        Expanded(
          child: Container(
            height: 38.36,
            margin: const EdgeInsets.only(
              left: 20.4,
            ),
            child: TextField(
              textInputAction: TextInputAction.next,
              onSubmitted: (_) => FocusScope.of(context).nextFocus(),
              readOnly: isReadOnly,
              onTap: () async {
                if (controller == dateInputController) {
                  /// 일시 입력 필드

                  // 년,월,일 묻는 팝업
                  DateTime? selectedDate = await _selectDate(context);
                  if (!mounted) {
                    return;
                  }

                  // 시간, 분 묻는 팝업
                  final TimeOfDay? timeOfDay = await showTimePicker(
                    context: context,
                    initialTime: initialTime,
                    initialEntryMode: TimePickerEntryMode.inputOnly,
                  );

                  // 모든 선택 끝나면 date string으로 변환하여 위젯에 표시
                  if (timeOfDay != null) {
                    setState(() {
                      initialTime = timeOfDay;
                      selectedDateTime = selectedDate!.add (Duration(hours: timeOfDay.hour, minutes: timeOfDay.minute));
                      dateInputController.text = DateFormat("yyyy.MM.dd E요일 HH시 mm분", "ko").format(selectedDateTime);
                    });
                  }

                } else if (controller == placeInputController) {
                  /// 장소 입력 필드인 경우

                } else {
                  /// 그 이외

                  return;
                }
              },
              controller: controller,
              style: const TextStyle(fontSize: 16.56),
              decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 13.95, vertical: 9.59),
                  suffixIcon: IconButton(
                    // Icon to
                    icon: const Stack(
                      alignment: AlignmentDirectional.center,
                      children: [
                        Icon(Icons.circle),
                        Icon(
                          Icons.close_rounded,
                          color: Colors.white,
                          size: 17,
                        )
                      ],
                    ), // clear text
                    onPressed: () => controller.clear(),
                  ),
                  focusColor: Colors.blueAccent,
                  border: const OutlineInputBorder(
                      borderRadius: BorderRadius.zero,
                      borderSide: BorderSide(color: Color(0xffD4D4D4)))),
            ),
          ),
        ),
      ],
    );
  }

  int getCategoryIndex() {
    int categoryIdx = -1;
    switch (dropdownValue) {
      case "프로그램":
        categoryIdx = Const.categoryProgram;
        break;

      case "축제/행사":
        categoryIdx = Const.categoryFestival;
        break;

      case "취업정보":
        categoryIdx = Const.categoryJob;
        break;

      case "소모임":
        categoryIdx = Const.categorySmallGroup;
        break;
    }
    return categoryIdx;
  }
}
