import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'dart:convert';
import 'dart:io';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:teams/environment.dart';
import 'package:teams/login.dart';
import 'package:teams/menuAbsen.dart';
import 'package:teams/menuAbsenOut.dart';
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
import 'package:string_extensions/string_extensions.dart';

import 'dashboard.dart';
import 'menuCuti.dart';
import 'menuPermitWithLetter.dart';

class menuProfil extends StatefulWidget {
  @override
  State<menuProfil> createState() => _menuProfilState();
}

class _menuProfilState extends State<menuProfil> {
  Timer _timer;
  var address = 'Getting Address..'.obs;
  bool _isLoading = true;
  bool _secureText = true;
  File avatarImg;
  File avatarImgName;
  File imageAttendance;
  File imageAttendance2;
  String stravatarImgName;
  int bottomIndex = 2;
  int employee_id;
  int payroll_employee_level;
  int days;
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
  final _key = new GlobalKey<FormState>();

  TextEditingController controllerusername;
  TextEditingController controllerpassword;

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

  insertAttendance() async {
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
            EasyLoading.show(status: 'loading...');
            var response = await request.send();
            if (response.statusCode == 200) {
              EasyLoading.showSuccess('Great Success!');
              EasyLoading.dismiss();
              print("Sukses");
            } else {
              print("Gagal");
            }
            showDialog(
                context: context,
                builder: (context) => CustomDialog(
                    locname: address.toString(),
                    imgurl: "$tostrimg.jpg",
                    title: "Absence Success",
                    date: "Date : $date",
                    time: "Time : $time",
                    ip: "IP Address : $wifiIP",
                    lat: "Latitude : ${_locationData.latitude}",
                    long: "Longtitude : ${_locationData.longitude}"));
          } else {
            if (distanceInMeters > maxDisCom) {
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
              EasyLoading.show(status: 'loading...');
              var response = await request.send();
              if (response.statusCode == 200) {
                EasyLoading.showSuccess('Great Success!');
                EasyLoading.dismiss();
                print("Sukses");
              } else {
                print("Gagal");
              }
              showDialog(
                  context: context,
                  builder: (context) => CustomDialog(
                      locname: address.toString(),
                      imgurl: "$tostrimg.jpg",
                      title: "Absence Success",
                      date: "Date : $date",
                      time: "Time : $time",
                      ip: "IP Address : $wifiIP",
                      lat: "Latitude : ${_locationData.latitude}",
                      long: "Longtitude : ${_locationData.longitude}"));
            }
          }
        }
      } else if (strmaxlate < strttimein) {
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
            EasyLoading.show(status: 'loading...');
            var response = await request.send();
            if (response.statusCode == 200) {
              EasyLoading.showSuccess('Great Success!');
              EasyLoading.dismiss();
              print("Sukses");
            } else {
              print("Gagal");
            }
            showDialog(
                context: context,
                builder: (context) => CustomDialog(
                    locname: address.toString(),
                    imgurl: "$tostrimg.jpg",
                    title: "Absence Success",
                    date: "Date : $date",
                    time: "Time : $time",
                    ip: "IP Address : $wifiIP",
                    lat: "Latitude : ${_locationData.latitude}",
                    long: "Longtitude : ${_locationData.longitude}"));
          } else {
            if (distanceInMeters > maxDisCom) {
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
              EasyLoading.show(status: 'loading...');
              var response = await request.send();
              if (response.statusCode == 200) {
                EasyLoading.showSuccess('Great Success!');
                EasyLoading.dismiss();
                print("Sukses");
              } else {
                print("Gagal");
              }
              showDialog(
                  context: context,
                  builder: (context) => CustomDialog(
                      locname: address.toString(),
                      imgurl: "$tostrimg.jpg",
                      title: "Absence Success",
                      date: "Date : $date",
                      time: "Time : $time",
                      ip: "IP Address : $wifiIP",
                      lat: "Latitude : ${_locationData.latitude}",
                      long: "Longtitude : ${_locationData.longitude}"));
            }
          }
        }
      }
    }
  }

  Future addAvatarImg() async {
    try {
      final XFile avatarImg =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (avatarImg == null) return;

      final avatarImgTemporary = File(avatarImg.path);
      final avatarImgTemName = File(avatarImg.name);
      setState(() {
        this.avatarImg = avatarImgTemporary;
        this.avatarImgName = avatarImgTemName;
        String strimg = avatarImgName.toString();
        String substrimg = strimg.substring(7);
        String substrimg2 = substrimg.substring(0, 18);
        String strexstension = strimg.substring(strimg.length - 5);
        String subexstension = strexstension.substring(0, 4);
        this.stravatarImgName = '$substrimg2$subexstension';
      });
    } on PlatformException catch (e) {
      print("Failed to pick image: $e");
    }
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      print(username);
      print(password);
      saveprofile();
    }
  }

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      employee_id = preferences.getInt("employee_id");
      username = preferences.getString("username");
      password = preferences.getString("password");
      avatar = preferences.getString("avatar");
      payroll_employee_level = preferences.getInt("payroll_employee_level");
      region_id = preferences.getString("region_id");
      branch_id = preferences.getString("branch_id");
      location_id = preferences.getString("location_id");
      division_id = preferences.getString("division_id");
      department_id = preferences.getString("department_id");
      section_id = preferences.getString("section_id");
      unit_id = preferences.getString("unit_id");
      shift_id = preferences.getString("shift_id");
      employee_shift_id = preferences.getString("employee_shift_id");
      department_code = preferences.getString("department_code");
      employee_rfid_code = preferences.getString("employee_rfid_code");
      days = preferences.getInt("days");
    });
  }

  saveprofile() async {
    if (avatarImg != null) {
      var url = Uri.parse("$env/teams/editprofile.php");
      var request = http.MultipartRequest('POST', url);
      request.fields['employee_id'] = employee_id.toString();
      request.fields['username'] = username;
      request.fields['password'] = password;
      var pic = await http.MultipartFile.fromPath("image", avatarImg.path);
      request.files.add(pic);
      var response = await request.send();
      if (response.statusCode == 200) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        setState(() {
          preferences.setString("username", username);
          preferences.setString("password", password);
          preferences.setString("avatar", stravatarImgName);
        });
        print("Sukses");
      } else {
        print("Gagal");
      }
    } else {
      var url = Uri.parse("$env/teams/editprofilenoimg.php");
      var request = http.MultipartRequest('POST', url);
      request.fields['employee_id'] = employee_id.toString();
      request.fields['username'] = username;
      request.fields['password'] = password;
      var response = await request.send();
      if (response.statusCode == 200) {
        SharedPreferences preferences = await SharedPreferences.getInstance();
        setState(() {
          preferences.setString("username", username);
          preferences.setString("password", password);
        });
        Fluttertoast.showToast(
            msg: "Edit Data Berhasil",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 5,
            backgroundColor: Color.fromARGB(255, 42, 46, 147),
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => menuProfil()),
          (Route<dynamic> route) => false,
        );
        print("Sukses");
      } else {
        Fluttertoast.showToast(
            msg: "Permintaan Cuti Berhasil",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 5,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => menuProfil()),
          (Route<dynamic> route) => false,
        );
        print("Gagal");
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    getPref();
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
    // EasyLoading.showSuccess('Use in initState');
    // EasyLoading.removeCallbacks();
  }

  @override
  Widget build(BuildContext context) {
    String newavatar = avatar;
    String newusername = username;
    String newpassword = password;
    controllerusername = new TextEditingController(text: '$newusername');
    controllerpassword = new TextEditingController(text: '$newpassword');
    print(controllerusername);
    print(controllerpassword);
    return Scaffold(
      body: SingleChildScrollView(
        child: SafeArea(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.91,
            // color: Colors.black,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(10, 10, 10, 25),
              child: Card(
                color: Color.fromARGB(255, 230, 243, 252),
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (_isLoading)
                        ...[]
                      else ...[
                        avatarImg != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: ClipOval(
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        ClipOval(
                                          child: Image.file(
                                            avatarImg,
                                            width: 200,
                                            height: 200,
                                            fit: BoxFit.fill,
                                          ),
                                        ),
                                        Positioned(
                                          bottom: 20,
                                          right: 15,
                                          child: CircleAvatar(
                                              radius: 15,
                                              child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                  onPressed: () {
                                                    addAvatarImg();
                                                  },
                                                  icon:
                                                      Icon(Icons.add_a_photo))),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              )
                            : Padding(
                                padding: const EdgeInsets.only(top: 2),
                                child: CircleAvatar(
                                  backgroundColor: Colors.transparent,
                                  backgroundImage: NetworkImage(
                                      '$env/teams/assets/images/profile/$newavatar'),
                                  radius: 100,
                                  child: Center(
                                    child: Stack(
                                      children: [
                                        Positioned(
                                          bottom: 20,
                                          right: 25,
                                          child: CircleAvatar(
                                              radius: 15,
                                              child: IconButton(
                                                  padding: EdgeInsets.zero,
                                                  constraints: BoxConstraints(),
                                                  onPressed: () {
                                                    addAvatarImg();
                                                  },
                                                  icon:
                                                      Icon(Icons.add_a_photo))),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                        Form(
                          key: _key,
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Username  :",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Richard-Samuels',
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  addHorizontalSpace(15),
                                  Container(
                                    padding: EdgeInsets.zero,
                                    decoration: UnderlineTabIndicator(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 2)),
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    height: 35,
                                    child: TextFormField(
                                      validator: (e) {
                                        if (e.isEmpty) {
                                          return "Please insert username";
                                        }
                                      },
                                      onSaved: (e) => username = e,
                                      initialValue: controllerusername.text,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Richard-Samuels',
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                      decoration: InputDecoration(
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    "Password  :",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Richard-Samuels',
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  addHorizontalSpace(15),
                                  Container(
                                    padding: EdgeInsets.zero,
                                    decoration: UnderlineTabIndicator(
                                        borderSide: BorderSide(
                                            color: Colors.grey, width: 2)),
                                    width:
                                        MediaQuery.of(context).size.width * 0.5,
                                    height: 35,
                                    child: TextFormField(
                                      validator: (e) {
                                        if (e.isEmpty) {
                                          return "Please insert password";
                                        }
                                      },
                                      obscureText: _secureText,
                                      onSaved: (e) => password = e,
                                      initialValue: controllerpassword.text,
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontFamily: 'Richard-Samuels',
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                      decoration: InputDecoration(
                                        suffixIcon: IconButton(
                                          padding: EdgeInsets.zero,
                                          constraints: BoxConstraints(),
                                          onPressed: showHide,
                                          icon: Icon(_secureText
                                              ? Icons.visibility_off
                                              : Icons.visibility),
                                        ),
                                        border: OutlineInputBorder(
                                            borderSide: BorderSide.none),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                              Padding(padding: EdgeInsets.only(top: 10.0)),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        right: 18, top: 7),
                                    child: ElevatedButton(
                                        onPressed: () {
                                          print(avatarImg);
                                          print(avatarImgName);
                                          print(stravatarImgName);
                                          print(username);
                                          print(password);
                                          check();
                                        },
                                        child: Text('simpan')),
                                  )
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                      Divider(),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.width * 0.55,
                        child: ListView(
                          children: [
                            Column(
                              children: [
                                ListTile(
                                  leading: Icon(
                                    Icons.history,
                                    color: Colors.black,
                                  ),
                                  title: Text(
                                    'History Absen Masuk',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Richard-Samuels',
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: GestureDetector(
                                    onTap: (() {
                                      Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  dataAbsenOut()));
                                    }),
                                    child: Icon(
                                      Icons.arrow_right_alt,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.history,
                                    color: Colors.black,
                                  ),
                                  title: Text(
                                    'History Absen Pulang',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Richard-Samuels',
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: GestureDetector(
                                    onTap: (() {
                                      Navigator.of(context).push(
                                          new MaterialPageRoute(
                                              builder: (BuildContext context) =>
                                                  dataAbsen()));
                                    }),
                                    child: Icon(
                                      Icons.arrow_right_alt,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                                ListTile(
                                  leading: Icon(
                                    Icons.paid,
                                    color: Colors.black,
                                  ),
                                  title: Text(
                                    'Slip Gaji',
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: 'Richard-Samuels',
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  trailing: Icon(
                                    Icons.arrow_right_alt,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
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
