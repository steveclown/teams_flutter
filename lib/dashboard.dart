import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:teams/environment.dart';
import 'package:teams/login.dart';
import 'package:teams/menuPermit.dart';
import 'package:teams/menuPermitNonLetter.dart';
import 'package:teams/menuProfile.dart';
import 'package:teams/widget_functions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:location/location.dart';
import 'package:geocoding/geocoding.dart' as geocod;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:wifi_info_flutter/wifi_info_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:rflutter_alert/rflutter_alert.dart';

import 'menuCuti.dart';
import 'menuPermitWithLetter.dart';

const CATEGORIES = [
  {"image": "icon-41.png", "name": "Notif 1"},
  {"image": "icon-41.png", "name": "Notif 2"},
  {"image": "icon-41.png", "name": "Notif 3"},
  {"image": "icon-41.png", "name": "Notif 4"},
  {"image": "icon-41.png", "name": "Notif 5"},
  {"image": "icon-41.png", "name": "Notif 6"},
  {"image": "icon-41.png", "name": "Notif 7"},
  {"image": "icon-41.png", "name": "Notif 8"},
  {"image": "icon-41.png", "name": "Notif 9"},
  {"image": "icon-41.png", "name": "Notif 10"},
];

class menuDashboard extends StatefulWidget {
  final VoidCallback signOut;
  menuDashboard(this.signOut);
  @override
  _menuDashboardState createState() => _menuDashboardState();
}

class _menuDashboardState extends State<menuDashboard> {
  LoginStatus _loginStatus;
  Timer _timer;
  var dataattendancelog = new Map();
  int days;
  bool _isLoading = true;

  int bottomIndex = 0;
  String _timeString;
  var address = 'Getting Address..'.obs;

  File imageAttendance;
  File imageAttendance2;
  int employee_id;
  int payroll_employee_level;
  String region_id = "",
      branch_id = "",
      location_id = "",
      division_id = "",
      department_id = "",
      section_id = "",
      unit_id = "",
      shift_id = "",
      employee_shift_id = "",
      username = "",
      password = "",
      avatar = "",
      department_code = "",
      employee_rfid_code = "",
      wifiIP = "",
      strimg = "",
      substrimg = "",
      substrimg2 = "",
      tostrimg = "";

  var showDate = DateFormat('EEEE', 'id_ID').format(DateTime.now());
  var showtime = DateFormat.Hm().format(DateTime.now());
  int value = 0;
  // TabController tabController;
  // LOAD DATA PREFERENCES

  alert() async {
    Alert(
      context: context,
      type: AlertType.warning,
      title: "Logging Out",
      desc: "Are you sure?",
      buttons: [
        DialogButton(
          child: Text(
            "Yes",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () async {
            SharedPreferences preferences =
                await SharedPreferences.getInstance();
            setState(() {
              preferences.setInt("value", 0);
              preferences.commit();
              preferences.clear();
              _loginStatus = LoginStatus.notSignIn;
            });
            Navigator.pop(context);
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Login()),
              (Route<dynamic> route) => false,
            );
          },
          color: Color.fromRGBO(0, 179, 134, 1.0),
        ),
        DialogButton(
          child: Text(
            "No",
            style: TextStyle(color: Colors.white, fontSize: 20),
          ),
          onPressed: () => Navigator.pop(context),
          gradient: LinearGradient(colors: [
            Color.fromARGB(255, 0, 162, 255),
            Color.fromARGB(255, 15, 131, 214)
          ]),
        )
      ],
    ).show();
  }

  // signOut() async {
  //   SharedPreferences preferences = await SharedPreferences.getInstance();
  //   setState(() {
  //     preferences.clear();
  //     widget.signOut();
  //   });
  // }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      region_id = preferences.getString("region_id");
      branch_id = preferences.getString("branch_id");
      location_id = preferences.getString("location_id");
      division_id = preferences.getString("division_id");
      department_id = preferences.getString("department_id");
      section_id = preferences.getString("section_id");
      unit_id = preferences.getString("unit_id");
      employee_id = preferences.getInt("employee_id");
      shift_id = preferences.getString("shift_id");
      employee_shift_id = preferences.getString("employee_shift_id");
      username = preferences.getString("username");
      password = preferences.getString("password");
      avatar = preferences.getString("avatar");
      payroll_employee_level = preferences.getInt("payroll_employee_level");
      department_code = preferences.getString("department_code");
      employee_rfid_code = preferences.getString("employee_rfid_code");
      value = preferences.getInt("value");
    });
  }

  Future getAttendanceLog() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    var employee_attendance_log_period =
        DateFormat('yyyyMM').format(DateTime.now());
    var today = DateFormat('dd').format(DateTime.now());
    int id = preferences.getInt("employee_id");
    var url = Uri.parse("$env/teams/getattendancelog.php");
    final response = await http.post(url, headers: {
      "Accept": "application/json",
      "Access-Control-Allow-Origin": "*",
    }, body: {
      "employee_id": '$id',
      "employee_attendance_log_period": '$employee_attendance_log_period'
    });
    var data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];
    if (value == 1) {
      setState(() {
        dataattendancelog = data;
        days = int.parse(data['0']['day_$today']);
        preferences.setInt("days", days);
      });
    } else {
      setState(() {
        dataattendancelog = data;
        days = 0;
        preferences.setInt("days", days);
      });
    }
  }

  insertAttendance() async {
    EasyLoading.show(status: 'Harap Tunggu...');
    // GET GPS
    Location location = new Location();
    bool _serviceEnabled;
    PermissionStatus _permissionGranted;
    LocationData _locationData;
    bool _isListenLocation = false, _isGetLocation = false;

    _serviceEnabled = await location.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await location.requestService();
      if (_serviceEnabled) return;
    }

    _permissionGranted = await location.hasPermission();
    if (_permissionGranted == PermissionStatus.denied) {
      _permissionGranted = await location.requestPermission();
      if (_permissionGranted != PermissionStatus.granted) return;
    }

    _locationData = await location.getLocation();
    setState(() {
      _isGetLocation = true;
    });

    //GET ADDRESS
    List<geocod.Placemark> placemark = await geocod.placemarkFromCoordinates(
        _locationData.latitude, _locationData.longitude,
        localeIdentifier: "en");
    geocod.Placemark place = placemark[0];
    address.value =
        '${place.street},${place.locality},${place.subAdministrativeArea},${place.country}';
    // '${place.subAdministrativeArea},${place.country}';
    print("address");
    print(address);
    setState(() {
      address();
    });

    // GET IP
    wifiIP = await WifiInfo().getWifiIP();
    setState(() {
      wifiIP;
    });

    // Calculate Distance
    var urlLat = Uri.parse("$env/teams/getlatlong.php");
    final responseLat = await http.get(urlLat);
    final dataLat = jsonDecode(responseLat.body);
    String company_latitude = dataLat[0]['company_latitude'];
    String company_longitude = dataLat[0]['company_longitude'];
    String company_max_distance = dataLat[0]['company_max_distance'];
    String company_max_attendance =
        dataLat[0]['employee_working_in_start_minute'];
    var latCom = double.parse(company_latitude);
    var longCom = double.parse(company_longitude);
    var maxDisCom = double.parse(company_max_distance);
    var plusLateAttendance = int.parse(company_max_attendance);

    var distanceInMeters = Geolocator.distanceBetween(
        latCom, longCom, _locationData.latitude, _locationData.longitude);
    print("DISTANCE");
    print(distanceInMeters);

    print("Max Late Attendance");
    print(plusLateAttendance);
    if (days > 1) {
      setState(() {
        bottomIndex = 0;
      });
      EasyLoading.dismiss();
      return Fluttertoast.showToast(
          msg: "Anda Sedang Cuti atau Sakit",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Color.fromARGB(255, 42, 46, 147),
          textColor: Colors.white,
          fontSize: 16.0);
    } else {
      var schedule_item_date = DateFormat('yyyy-MM-dd').format(DateTime.now());
      var url = Uri.parse("$env/teams/getmaxlateattendance.php");
      final response = await http.post(url, headers: {
        "Accept": "application/json",
        "Access-Control-Allow-Origin": "*",
      }, body: {
        "employee_id": employee_id.toString(),
        "schedule_item_date": schedule_item_date
      });
      var data = jsonDecode(response.body);
      String pesan = data['message'];
      int valuemaxtimein = data['value'];
      String employee_schedule_item_date =
          data['0']['employee_schedule_item_in_start_date'];
      String employee_schedule_item_out_date =
          data['0']['employee_schedule_item_out_start_date'];
      print(employee_schedule_item_date);
      print(employee_schedule_item_out_date);
      print(valuemaxtimein);
      print(pesan);
      var defaultLateAttendance = DateTime.parse(employee_schedule_item_date);
      var maxLateAttendance = defaultLateAttendance.add(Duration(minutes: 210));
      var defaultOutAttendance =
          DateTime.parse(employee_schedule_item_out_date);
      var mindefaultOutAttendance =
          defaultOutAttendance.subtract(Duration(days: 1));

      var strttimein = DateTime.now().millisecondsSinceEpoch;
      var strmaxlate = maxLateAttendance.millisecondsSinceEpoch;
      var strmaxovertime = mindefaultOutAttendance.millisecondsSinceEpoch;

      print(mindefaultOutAttendance);
      print(strttimein);
      print(strmaxlate);
      print(strmaxovertime);
      print('defaultLateAttendance');
      print(defaultLateAttendance);

      print('maxLateAttendance');
      print(maxLateAttendance);

      if (strmaxovertime < strttimein) {
        print("OVERTIME");
        // OVERTIME
        //CHECK DATA ATTENDANCE TODAY
        var employee_attendance_date =
            DateFormat('yyyy-MM-dd').format(DateTime.now());
        var url = Uri.parse("$env/teams/getdataattendancecheck.php");
        final response = await http.post(url, headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*",
        }, body: {
          "employee_id": employee_id.toString(),
          "employee_attendance_date": '$employee_attendance_date'
        });
        var data = jsonDecode(response.body);
        int valueattendancecheck = data['value'];
        int countattendancecheck =
            int.parse(data['0']['COUNT(employee_attendance_id)']);
        String pesan = data['message'];
        print(data['0']['COUNT(employee_attendance_id)']);
        print(employee_attendance_date);
        print(valueattendancecheck);
        print(pesan);
        if (countattendancecheck > 1) {
          setState(() {
            bottomIndex = 0;
          });
          EasyLoading.dismiss();
          return Fluttertoast.showToast(
              msg: "Proses Absensi Gagal",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 5,
              backgroundColor: Color.fromARGB(255, 42, 46, 147),
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          if (payroll_employee_level > 0) {
            // GET IMAGE
            final ImagePicker _picker = ImagePicker();
            final XFile imagePicked =
                await _picker.pickImage(source: ImageSource.camera);
            imageAttendance = File(imagePicked.path);
            imageAttendance2 = File(imagePicked.name);
            setState(() {
              imageAttendance = File(imagePicked.path);
              imageAttendance2 = File(imagePicked.name);
              strimg = imageAttendance2.toString();
              substrimg = strimg.substring(7);
              substrimg2 = substrimg.substring(0, 18);
              tostrimg = substrimg2.toString();
            });
            // INSERT ATTENDANCE
            var date = DateFormat('yyyy-MM-dd').format(DateTime.now());
            var periode = DateFormat('yyyyMM').format(DateTime.now());
            var days = DateFormat('dd').format(DateTime.now());
            var dt = DateFormat('yyyy-MM-dd').add_Hms().format(DateTime.now());
            var time = DateFormat.Hms().format(DateTime.now());
            var url = Uri.parse("$env/teams/insertattendance.php");
            var request = http.MultipartRequest('POST', url);
            request.fields['region_id'] = region_id;
            request.fields['branch_id'] = branch_id;
            request.fields['division_id'] = division_id;
            request.fields['department_id'] = department_id;
            request.fields['section_id'] = section_id;
            request.fields['unit_id'] = unit_id;
            request.fields['location_id'] = location_id;
            request.fields['shift_id'] = shift_id;
            request.fields['employee_shift_id'] = employee_shift_id;
            request.fields['employee_id'] = employee_id.toString();
            request.fields['employee_rfid_code'] = employee_rfid_code;
            request.fields['periode'] = periode;
            request.fields['days'] = days;
            request.fields['employee_attendance_in_status'] = "1";
            request.fields['employee_attendance_out_status'] = "0";
            request.fields['employee_attendance_date'] = date;
            request.fields['employee_attendance_log_date'] = dt;
            request.fields['employee_attendance_log_in_date'] = dt;
            request.fields['employee_attendance_log_out_date'] = dt;
            request.fields['machine_ip_address'] = wifiIP;
            request.fields['employee_attendance_location_in'] =
                "${_locationData.latitude} , ${_locationData.longitude}";
            request.fields['employee_attendance_location_out'] =
                "${_locationData.latitude} , ${_locationData.longitude}";
            request.fields['employee_attendance_location_address'] =
                address.toString();
            var pic = await http.MultipartFile.fromPath(
                "image", imageAttendance.path);
            request.files.add(pic);
            var response = await request.send();
            if (response.statusCode == 200) {
              EasyLoading.showSuccess('Absen Sukses!');
              EasyLoading.dismiss();
              print("Sukses");
            } else {
              print("Gagal");
            }
            // showDialog(
            //     context: context,
            //     builder: (context) => CustomDialog(
            //         locname: address.toString(),
            //         imgurl: "$tostrimg.jpg",
            //         title: "Absence Success",
            //         date: "Date : $date",
            //         time: "Time : $time",
            //         ip: "IP Address : $wifiIP",
            //         lat: "Latitude : ${_locationData.latitude}",
            //         long: "Longtitude : ${_locationData.longitude}"));
          } else {
            if (distanceInMeters > maxDisCom) {
              EasyLoading.dismiss();
              return Fluttertoast.showToast(
                  msg: "Lokasi terlalu jauh",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 5,
                  backgroundColor: Color.fromARGB(255, 42, 46, 147),
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              print("INSERT ATTENDANCE");
              // GET IMAGE
              final ImagePicker _picker = ImagePicker();
              final XFile imagePicked =
                  await _picker.pickImage(source: ImageSource.camera);
              imageAttendance = File(imagePicked.path);
              imageAttendance2 = File(imagePicked.name);
              setState(() {
                imageAttendance = File(imagePicked.path);
                imageAttendance2 = File(imagePicked.name);
                strimg = imageAttendance2.toString();
                substrimg = strimg.substring(7);
                substrimg2 = substrimg.substring(0, 18);
                tostrimg = substrimg2.toString();
              });

              // INSERT ATTENDANCE
              var date = DateFormat('yyyy-MM-dd').format(DateTime.now());
              var periode = DateFormat('yyyyMM').format(DateTime.now());
              var days = DateFormat('dd').format(DateTime.now());
              var dt =
                  DateFormat('yyyy-MM-dd').add_Hms().format(DateTime.now());
              var time = DateFormat.Hms().format(DateTime.now());
              var url = Uri.parse("$env/teams/insertattendance.php");
              var request = http.MultipartRequest('POST', url);
              request.fields['region_id'] = region_id;
              request.fields['branch_id'] = branch_id;
              request.fields['division_id'] = division_id;
              request.fields['department_id'] = department_id;
              request.fields['section_id'] = section_id;
              request.fields['unit_id'] = unit_id;
              request.fields['location_id'] = location_id;
              request.fields['shift_id'] = shift_id;
              request.fields['employee_shift_id'] = employee_shift_id;
              request.fields['employee_id'] = employee_id.toString();
              request.fields['employee_rfid_code'] = employee_rfid_code;
              request.fields['periode'] = periode;
              request.fields['days'] = days;
              request.fields['employee_attendance_in_status'] = "1";
              request.fields['employee_attendance_out_status'] = "0";
              request.fields['employee_attendance_date'] = date;
              request.fields['employee_attendance_log_date'] = dt;
              request.fields['employee_attendance_log_in_date'] = dt;
              request.fields['employee_attendance_log_out_date'] = dt;
              request.fields['machine_ip_address'] = wifiIP;
              request.fields['employee_attendance_location_in'] =
                  "${_locationData.latitude} , ${_locationData.longitude}";
              request.fields['employee_attendance_location_out'] =
                  "${_locationData.latitude} , ${_locationData.longitude}";
              request.fields['employee_attendance_location_address'] =
                  address.toString();
              var pic = await http.MultipartFile.fromPath(
                  "image", imageAttendance.path);
              request.files.add(pic);
              var response = await request.send();
              if (response.statusCode == 200) {
                EasyLoading.showSuccess('Absen Sukses!');
                EasyLoading.dismiss();
                print("Sukses");
              } else {
                print("Gagal");
              }
              // showDialog(
              //     context: context,
              //     builder: (context) => CustomDialog(
              //         locname: address.toString(),
              //         imgurl: "$tostrimg.jpg",
              //         title: "Absence Success",
              //         date: "Date : $date",
              //         time: "Time : $time",
              //         ip: "IP Address : $wifiIP",
              //         lat: "Latitude : ${_locationData.latitude}",
              //         long: "Longtitude : ${_locationData.longitude}"));
            }
          }
        }
      } else if (strmaxlate < strttimein) {
        EasyLoading.dismiss();
        return Fluttertoast.showToast(
            msg: "Sudah Melebihi Batas Absen!",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 5,
            backgroundColor: Color.fromARGB(255, 42, 46, 147),
            textColor: Colors.white,
            fontSize: 16.0);
      } else {
        // ABSENCE
        //CHECK DATA ATTENDANCE TODAY
        var employee_attendance_date =
            DateFormat('yyyy-MM-dd').format(DateTime.now());
        var url = Uri.parse("$env/teams/getdataattendancecheck.php");
        final response = await http.post(url, headers: {
          "Accept": "application/json",
          "Access-Control-Allow-Origin": "*",
        }, body: {
          "employee_id": employee_id.toString(),
          "employee_attendance_date": '$employee_attendance_date'
        });
        var data = jsonDecode(response.body);
        int valueattendancecheck = data['value'];
        int countattendancecheck =
            int.parse(data['0']['COUNT(employee_attendance_id)']);
        String pesan = data['message'];
        print(data['0']['COUNT(employee_attendance_id)']);
        print(employee_attendance_date);
        print(valueattendancecheck);
        print(pesan);
        if (countattendancecheck > 0) {
          setState(() {
            bottomIndex = 0;
          });
          EasyLoading.dismiss();
          return Fluttertoast.showToast(
              msg: "Proses Absensi Sudah Dilakukan!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 5,
              backgroundColor: Color.fromARGB(255, 42, 46, 147),
              textColor: Colors.white,
              fontSize: 16.0);
        } else {
          if (payroll_employee_level > 0) {
            // GET IMAGE
            final ImagePicker _picker = ImagePicker();
            final XFile imagePicked =
                await _picker.pickImage(source: ImageSource.camera);
            imageAttendance = File(imagePicked.path);
            imageAttendance2 = File(imagePicked.name);
            setState(() {
              imageAttendance = File(imagePicked.path);
              imageAttendance2 = File(imagePicked.name);
              strimg = imageAttendance2.toString();
              substrimg = strimg.substring(7);
              substrimg2 = substrimg.substring(0, 18);
              tostrimg = substrimg2.toString();
            });
            // INSERT ATTENDANCE
            var date = DateFormat('yyyy-MM-dd').format(DateTime.now());
            var periode = DateFormat('yyyyMM').format(DateTime.now());
            var days = DateFormat('dd').format(DateTime.now());
            var dt = DateFormat('yyyy-MM-dd').add_Hms().format(DateTime.now());
            var time = DateFormat.Hms().format(DateTime.now());
            var url = Uri.parse("$env/teams/insertattendance.php");
            var request = http.MultipartRequest('POST', url);
            request.fields['region_id'] = region_id;
            request.fields['branch_id'] = branch_id;
            request.fields['division_id'] = division_id;
            request.fields['department_id'] = department_id;
            request.fields['section_id'] = section_id;
            request.fields['unit_id'] = unit_id;
            request.fields['location_id'] = location_id;
            request.fields['shift_id'] = shift_id;
            request.fields['employee_shift_id'] = employee_shift_id;
            request.fields['employee_id'] = employee_id.toString();
            request.fields['employee_rfid_code'] = employee_rfid_code;
            request.fields['periode'] = periode;
            request.fields['days'] = days;
            request.fields['employee_attendance_in_status'] = "1";
            request.fields['employee_attendance_out_status'] = "0";
            request.fields['employee_attendance_date'] = date;
            request.fields['employee_attendance_log_date'] = dt;
            request.fields['employee_attendance_log_in_date'] = dt;
            request.fields['employee_attendance_log_out_date'] = dt;
            request.fields['machine_ip_address'] = wifiIP;
            request.fields['employee_attendance_location_in'] =
                "${_locationData.latitude} , ${_locationData.longitude}";
            request.fields['employee_attendance_location_out'] =
                "${_locationData.latitude} , ${_locationData.longitude}";
            request.fields['employee_attendance_location_address'] =
                address.toString();
            var pic = await http.MultipartFile.fromPath(
                "image", imageAttendance.path);
            request.files.add(pic);
            var response = await request.send();
            if (response.statusCode == 200) {
              EasyLoading.showSuccess('Absen Sukses!');
              EasyLoading.dismiss();
              print("Sukses");
            } else {
              print("Gagal");
            }
            // showDialog(
            //     context: context,
            //     builder: (context) => CustomDialog(
            //         locname: address.toString(),
            //         imgurl: "$tostrimg.jpg",
            //         title: "Absence Success",
            //         date: "Date : $date",
            //         time: "Time : $time",
            //         ip: "IP Address : $wifiIP",
            //         lat: "Latitude : ${_locationData.latitude}",
            //         long: "Longtitude : ${_locationData.longitude}"));
          } else {
            if (distanceInMeters > maxDisCom) {
              EasyLoading.dismiss();
              return Fluttertoast.showToast(
                  msg: "Lokasi terlalu jauh",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.CENTER,
                  timeInSecForIosWeb: 5,
                  backgroundColor: Color.fromARGB(255, 42, 46, 147),
                  textColor: Colors.white,
                  fontSize: 16.0);
            } else {
              print("INSERT ATTENDANCE");
              // GET IMAGE
              final ImagePicker _picker = ImagePicker();
              final XFile imagePicked =
                  await _picker.pickImage(source: ImageSource.camera);
              imageAttendance = File(imagePicked.path);
              imageAttendance2 = File(imagePicked.name);
              setState(() {
                imageAttendance = File(imagePicked.path);
                imageAttendance2 = File(imagePicked.name);
                strimg = imageAttendance2.toString();
                substrimg = strimg.substring(7);
                substrimg2 = substrimg.substring(0, 18);
                tostrimg = substrimg2.toString();
              });

              // INSERT ATTENDANCE
              var date = DateFormat('yyyy-MM-dd').format(DateTime.now());
              var periode = DateFormat('yyyyMM').format(DateTime.now());
              var days = DateFormat('dd').format(DateTime.now());
              var dt =
                  DateFormat('yyyy-MM-dd').add_Hms().format(DateTime.now());
              var time = DateFormat.Hms().format(DateTime.now());
              var url = Uri.parse("$env/teams/insertattendance.php");
              var request = http.MultipartRequest('POST', url);
              request.fields['region_id'] = region_id;
              request.fields['branch_id'] = branch_id;
              request.fields['division_id'] = division_id;
              request.fields['department_id'] = department_id;
              request.fields['section_id'] = section_id;
              request.fields['unit_id'] = unit_id;
              request.fields['location_id'] = location_id;
              request.fields['shift_id'] = shift_id;
              request.fields['employee_shift_id'] = employee_shift_id;
              request.fields['employee_id'] = employee_id.toString();
              request.fields['employee_rfid_code'] = employee_rfid_code;
              request.fields['periode'] = periode;
              request.fields['days'] = days;
              request.fields['employee_attendance_in_status'] = "1";
              request.fields['employee_attendance_out_status'] = "0";
              request.fields['employee_attendance_date'] = date;
              request.fields['employee_attendance_log_date'] = dt;
              request.fields['employee_attendance_log_in_date'] = dt;
              request.fields['employee_attendance_log_out_date'] = dt;
              request.fields['machine_ip_address'] = wifiIP;
              request.fields['employee_attendance_location_in'] =
                  "${_locationData.latitude} , ${_locationData.longitude}";
              request.fields['employee_attendance_location_out'] =
                  "${_locationData.latitude} , ${_locationData.longitude}";
              request.fields['employee_attendance_location_address'] =
                  address.toString();
              var pic = await http.MultipartFile.fromPath(
                  "image", imageAttendance.path);
              request.files.add(pic);
              var response = await request.send();
              if (response.statusCode == 200) {
                EasyLoading.showSuccess('Absen Sukses!');
                EasyLoading.dismiss();
                print("Sukses");
              } else {
                print("Gagal");
              }
              // showDialog(
              //     context: context,
              //     builder: (context) => CustomDialog(
              //         locname: address.toString(),
              //         imgurl: "$tostrimg.jpg",
              //         title: "Absence Success",
              //         date: "Date : $date",
              //         time: "Time : $time",
              //         ip: "IP Address : $wifiIP",
              //         lat: "Latitude : ${_locationData.latitude}",
              //         long: "Longtitude : ${_locationData.longitude}"));
            }
          }
        }
      }
    }
  }

  void configLoading() {
    EasyLoading.instance
      ..displayDuration = const Duration(milliseconds: 2000)
      ..indicatorType = EasyLoadingIndicatorType.fadingFour
      ..loadingStyle = EasyLoadingStyle.dark
      ..indicatorSize = 45.0
      ..radius = 10.0
      ..progressColor = Colors.yellow
      ..backgroundColor = Colors.green
      ..indicatorColor = Colors.yellow
      ..textColor = Colors.yellow
      ..maskColor = Colors.blue.withOpacity(0.5)
      ..userInteractions = false
      ..dismissOnTap = false;
    // ..customAnimation = CustomAnimation();
  }

  void _selectedIndex(int index) {
    setState(() {
      bottomIndex = index;
    });
    {
      if (bottomIndex == 0) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => menuDashboard(() {})),
          (Route<dynamic> route) => false,
        );
      } else if (bottomIndex == 1) {
        setState(() {
          bottomIndex = 0;
        });
        insertAttendance();
      } else if (bottomIndex == 2) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => menuProfil()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _timeString = _formatDateTime(DateTime.now());
    Timer.periodic(Duration(seconds: 1), (Timer t) => _getTime());
    getPref();
    getAttendanceLog();
    configLoading();
    super.initState();
    Timer(Duration(seconds: 1), () {
      setState(() {
        _isLoading = false;
      });
    });
    EasyLoading.addStatusCallback((status) {
      print('EasyLoading Status $status');
      if (status == EasyLoadingStatus.dismiss) {
        _timer?.cancel();
      }
    });
    // EasyLoading.show(status: 'loading...');
    // EasyLoading.showSuccess('Use in initState');
    // EasyLoading.removeCallbacks();
    EasyLoading.dismiss();
  }

  void _getTime() {
    final DateTime now = DateTime.now();
    final String formattedDateTime = _formatDateTime(now);
    if (this.mounted) {
      setState(() {
        _timeString = formattedDateTime;
      });
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return DateFormat.Hms().format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    String newavatar = avatar;
    // print(avatar);
    // print('newavatar');
    // print(newavatar);
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text(
          "Teams.",
          style:
              TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
        backgroundColor: Color.fromARGB(255, 41, 71, 135),
        elevation: 2,
        actions: <Widget>[
          IconButton(
            onPressed: () {
              alert();
            },
            icon: Icon(Icons.lock_open),
          )
        ],
      ),
      body: LayoutBuilder(builder: (context, constraints) {
        return Container(
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Color.fromARGB(255, 41, 71, 135),
                        borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            bottomRight: Radius.circular(15)),
                      ),
                    ),
                    // Image.asset("assets/icon/")
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                child: Row(
                                  children: [
                                    if (_isLoading)
                                      ...[]
                                    else ...[
                                      Padding(
                                        padding: EdgeInsets.zero,
                                        child: CircleAvatar(
                                          backgroundImage: NetworkImage(
                                              '$env/teams/assets/images/profile/$newavatar'),
                                          backgroundColor: Colors.transparent,
                                          minRadius: 30,
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.only(left: 5),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Selamat Datang,",
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                fontFamily: 'Montserrat',
                                              ),
                                            ),
                                            addVerticalSpace(5),
                                            Text(
                                              username.capitalize,
                                              style: TextStyle(
                                                  fontSize: 20,
                                                  fontFamily: 'Montserrat',
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            addVerticalSpace(5),
                                            Text(
                                              department_code,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 40),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              showDate,
                                              style: TextStyle(
                                                fontSize: 13,
                                                fontWeight: FontWeight.bold,
                                                fontFamily: 'Montserrat',
                                                color: Colors.white,
                                              ),
                                            ),
                                            addVerticalSpace(8),
                                            Text(
                                              _timeString,
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  color: Colors.white,
                                                  fontFamily: 'Montserrat',
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            addVerticalSpace(12),
                                            Text(
                                              '',
                                              style: TextStyle(
                                                  fontSize: 10,
                                                  fontWeight: FontWeight.bold,
                                                  fontFamily: 'Montserrat',
                                                  color: Colors.grey),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ]
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: constraints.maxHeight,
                // color: Color.fromARGB(255, 0, 167, 230),
                height: MediaQuery.of(context).size.height * 0.4,
                child: Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 10),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      Card(
                        elevation: 10,
                        color: Color.fromARGB(255, 230, 243, 252),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(10, 0, 0, 30),
                          child: Container(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Center(
                                      child: Column(children: [
                                        IconButton(
                                            onPressed: () {},
                                            icon: Image.asset(
                                                'assets/icon/08/icon-41.png'),
                                            iconSize: 60,
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints()),
                                        Text(
                                          "Lembur",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Montserrat',
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          "",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Montserrat',
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]),
                                    ),
                                    Center(
                                      child: Column(children: [
                                        IconButton(
                                            onPressed: () {
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        dataCuti()),
                                                (Route<dynamic> route) => false,
                                              );
                                            },
                                            icon: Image.asset(
                                                'assets/icon/08/icon-42.png'),
                                            iconSize: 60,
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints()),
                                        Text(
                                          "Cuti",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Montserrat',
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          "",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Montserrat',
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]),
                                    ),
                                    Center(
                                      child: Column(children: [
                                        IconButton(
                                            onPressed: () {},
                                            icon: Image.asset(
                                                'assets/icon/08/icon-43.png'),
                                            iconSize: 60,
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints()),
                                        Text(
                                          "Perjalanan",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Montserrat',
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          "Bisnis",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Montserrat',
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ],
                                ),

// Baris ke - 2
                                Padding(padding: EdgeInsets.only(top: 25)),

                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Center(
                                      child: Column(children: [
                                        IconButton(
                                            onPressed: () {
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        dataIjin()),
                                                (Route<dynamic> route) => false,
                                              );
                                            },
                                            icon: Image.asset(
                                                'assets/icon/08/icon-46.png'),
                                            iconSize: 60,
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints()),
                                        Text(
                                          "Ijin",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Montserrat',
                                              color: Colors.black),
                                        ),
                                        Text(
                                          "",
                                          style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Montserrat',
                                              color: Colors.black),
                                        ),
                                      ]),
                                    ),
                                    Center(
                                      child: Column(children: [
                                        IconButton(
                                            onPressed: () {
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        dataIjinWithLetter()),
                                                (Route<dynamic> route) => false,
                                              );
                                            },
                                            icon: Image.asset(
                                                'assets/icon/08/icon-47.png'),
                                            iconSize: 60,
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints()),
                                        Text(
                                          "Ijin",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Montserrat',
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          "Dengan Surat",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Montserrat',
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]),
                                    ),
                                    Center(
                                      child: Column(children: [
                                        IconButton(
                                            onPressed: () {
                                              Navigator.pushAndRemoveUntil(
                                                context,
                                                MaterialPageRoute(
                                                    builder: (context) =>
                                                        dataIjinNonLetter()),
                                                (Route<dynamic> route) => false,
                                              );
                                            },
                                            icon: Image.asset(
                                                'assets/icon/08/icon-48.png'),
                                            iconSize: 60,
                                            padding: EdgeInsets.zero,
                                            constraints: BoxConstraints()),
                                        Text(
                                          "Ijin",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Montserrat',
                                            color: Colors.black,
                                          ),
                                        ),
                                        Text(
                                          "Tanpa Surat",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                            fontFamily: 'Montserrat',
                                            color: Colors.black,
                                          ),
                                        ),
                                      ]),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Positioned(
                      //   top: -30,
                      //   left: 0,
                      //   child: Container(
                      //     width: constraints.maxWidth,
                      //     height: constraints.maxHeight * 0.12,
                      //     child: Padding(
                      //       padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
                      //       child: ListView(
                      //           scrollDirection: Axis.horizontal,
                      //           physics: BouncingScrollPhysics(),
                      //           children: CATEGORIES
                      //               .map(
                      //                 (category) => Padding(
                      //                   padding: const EdgeInsets.fromLTRB(
                      //                       4, 0, 14, 0),
                      //                   child: Card(
                      //                     color: Color.fromARGB(
                      //                         255, 230, 243, 252),
                      //                     elevation: 5,
                      //                     shape: RoundedRectangleBorder(
                      //                         borderRadius:
                      //                             BorderRadius.circular(10.0)),
                      //                     child: Container(
                      //                       // margin:
                      //                       //     EdgeInsets.only(right: 10.0),
                      //                       width: constraints.maxWidth * 0.16,
                      //                       height:
                      //                           constraints.maxHeight * 0.16,
                      //                       decoration: BoxDecoration(
                      //                         borderRadius:
                      //                             BorderRadius.circular(10.0),
                      //                       ),
                      //                       child: Center(
                      //                         child: Column(
                      //                           mainAxisAlignment:
                      //                               MainAxisAlignment.center,
                      //                           crossAxisAlignment:
                      //                               CrossAxisAlignment.center,
                      //                           children: [
                      //                             Image.asset(
                      //                               "assets/icon/08/${category['image']}",
                      //                               width: 30,
                      //                               height: 30,
                      //                             ),
                      //                             // SizedBox(height: 2),
                      //                             Text(
                      //                               "${category['name']}",
                      //                               style: TextStyle(
                      //                                   color: Colors.black,
                      //                                   fontFamily:
                      //                                       'Montserrat',
                      //                                   fontSize: 10,
                      //                                   fontWeight:
                      //                                       FontWeight.w700),
                      //                             ),
                      //                           ],
                      //                         ),
                      //                       ),
                      //                     ),
                      //                   ),
                      //                 ),
                      //               )
                      //               .toList()),
                      //     ),
                      //   ),
                      // )
                    ],
                  ),
                ),
              ),

              // FEATURE IMAGES
              Padding(
                padding: const EdgeInsets.fromLTRB(10, 0, 10, 30),
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  height: MediaQuery.of(context).size.height * 0.15,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(25),
                      color: Color.fromARGB(255, 230, 243, 252),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 1,
                          blurRadius: 3,
                          offset: Offset(0, 3), // changes position of shadow
                        ),
                      ],
                      image: DecorationImage(
                          image: AssetImage(
                              'assets/icon/background/feature-images.jpg'),
                          // opacity: 75,
                          fit: BoxFit.cover)),
                  child: Center(
                      child: Text(
                    "Feature Images/News",
                    style: TextStyle(
                      fontSize: 25,
                      foreground: Paint()
                        ..style = PaintingStyle.stroke
                        ..strokeWidth = 1
                        ..color = Colors.white,
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    ),
                  )),
                ),
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: ConvexAppBar(
        backgroundColor: Color.fromARGB(255, 41, 71, 135),
        initialActiveIndex: bottomIndex,
        height: 35,
        cornerRadius: 15,
        top: -20,
        curveSize: 60,
        style: TabStyle.fixedCircle,
        items: [
          TabItem(icon: Icons.home),
          TabItem(icon: Icons.photo_camera),
          TabItem(icon: Icons.manage_accounts),
        ],
        onTap: _selectedIndex,
      ),
    );
  }
}

class CustomDialog extends StatelessWidget {
  String imgurl, title, date, ip, lat, long, buttonText, time, locname;
  Image image;

  CustomDialog(
      {this.imgurl,
      this.title,
      this.date,
      this.ip,
      this.lat,
      this.long,
      this.buttonText,
      this.time,
      this.locname,
      this.image});
  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: dialogContent(context),
    );
  }

  dialogContent(BuildContext context) {
    return Stack(
      children: <Widget>[
        Container(
          padding: EdgeInsets.only(top: 100, bottom: 16, left: 16, right: 16),
          decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.rectangle,
              borderRadius: BorderRadius.circular(17),
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10.0,
                  offset: Offset(0.0, 10.0),
                )
              ]),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 10.0,
              ),
              Text(title,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  )),
              SizedBox(
                height: 30.0,
              ),
              Text(date,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  )),
              Text(time,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  )),
              Text(ip,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  )),
              Text(lat,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  )),
              Text(long,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  )),
              Text(locname,
                  textAlign: TextAlign.start,
                  style: TextStyle(
                    fontSize: 10.0,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Montserrat',
                  )),
              SizedBox(height: 10.0),
              Align(
                alignment: Alignment.bottomRight,
                child: OutlinedButton(
                  style: ButtonStyle(
                      backgroundColor: MaterialStateProperty.all(
                    Colors.white,
                  )),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text("Confirm",
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ),
        Positioned(
          top: 5,
          left: 16,
          right: 16,
          child: Image(
            image: AssetImage("assets/images/verified.png"),
            width: 100,
            height: 100,
          ),
        )
      ],
    );
  }
}
