import 'dart:io';

import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:teams/menuPermit.dart';
import 'package:teams/widget_functions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard.dart';
import 'environment.dart';
import 'menuCuti.dart';
import 'menuProfile.dart';

class formPermit extends StatefulWidget {
  @override
  State<formPermit> createState() => _formPermitState();
}

class _formPermitState extends State<formPermit> {
  File image;
  List datacategorypermit = List();
  String categorypermit;
  int employee_id;
  String strdatestart = "";
  String strdateend = "";
  String keteranganpermit = "";
  DateTime datestart;
  DateTime dateend;
  int bottomIndex = 0;

  String getDateStart() {
    if (datestart == null) {
      return 'Select Date';
    } else {
      setState(() {
        strdatestart = DateFormat('yyyy-MM-dd').format(datestart);
      });
      return DateFormat('yyyy-MM-dd').format(datestart);
    }
  }

  String getDateEnd() {
    if (dateend == null) {
      return 'Select Date';
    } else {
      setState(() {
        strdateend = DateFormat('yyyy-MM-dd').format(dateend);
      });
      return DateFormat('yyyy-MM-dd').format(dateend);
    }
  }

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      employee_id = preferences.getInt("employee_id");
    });
  }

  Future getCategoryPermit() async {
    var url = Uri.parse("$env/teams/getcategorypermit.php");
    final response = await http.get(url, headers: {
      "Accept": "application/json",
      "Access-Control-Allow-Origin": "*",
    });
    var data = jsonDecode(response.body);
    setState(() {
      datacategorypermit = data;
    });
    print(data);
  }

  Future addImage() async {
    try {
      final XFile image =
          await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;

      final imageTemporary = File(image.path);
      setState(() => this.image = imageTemporary);
    } on PlatformException catch (e) {
      print("Failed to pick image: $e");
    }
  }

  savepermit() async {
    int duration = dateend.difference(datestart).inDays;
    var periode = DateFormat('yyyyMM').format(DateTime.now());
    var days = DateFormat('dd').format(DateTime.now());
    var url = Uri.parse("$env/teams/insertpermit.php");
    var request = http.MultipartRequest('POST', url);
    request.fields['employee_id'] = employee_id.toString();
    request.fields['permit_id'] = categorypermit;
    request.fields['employee_attendance_data_id'] = '1';
    request.fields['employee_permit_date'] = strdatestart;
    request.fields['employee_permit_start_date'] = strdatestart;
    request.fields['employee_permit_end_date'] = strdateend;
    request.fields['employee_permit_description'] = keteranganpermit;
    request.fields['employee_permit_duration'] = duration.toString();
    request.fields['employee_permit_whole_days'] = duration.toString();
    request.fields['permit_type'] = '1';
    request.fields['deduction_type'] = '1';
    request.fields['employee_attendance_date_status'] = "1";
    request.fields['periode'] = periode;
    request.fields['days'] = days;
    var pic = await http.MultipartFile.fromPath("image", image.path);
    request.files.add(pic);
    var response = await request.send();
    if (response.statusCode == 200) {
      Fluttertoast.showToast(
          msg: "Pengajuan Ijin Berhasil",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 12,
          backgroundColor: Color.fromARGB(255, 42, 46, 147),
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => dataIjin()),
        (Route<dynamic> route) => false,
      );
      print("Sukses");
    } else {
      print("Gagal");
    }
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
        print(bottomIndex);
      } else if (bottomIndex == 2) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => dataCuti()),
          (Route<dynamic> route) => false,
        );
      }
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
    getCategoryPermit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 41, 71, 135),
        title: Text(
          "Form Permit",
          style:
              TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.82,
          // color: Colors.black,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 25),
            child: Card(
              color: Color.fromARGB(255, 230, 243, 252),
              elevation: 10,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0)),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          "Pilih Kategori :",
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Richard-Samuels',
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        addHorizontalSpace(5),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.55,
                          child: Center(
                            child: DropdownButton(
                                style: TextStyle(
                                  color: Color.fromARGB(255, 2, 34, 104),
                                ),
                                value: categorypermit,
                                hint: Text(
                                  "Select Category",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Richard-Samuels',
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                                items: datacategorypermit.map(
                                  (list) {
                                    return DropdownMenuItem(
                                      child: Text(list['permit_name'],
                                          style: TextStyle(
                                                  fontSize: 12,
                                                  fontFamily: 'Richard-Samuels',
                                                  color: Colors.black,
                                                  fontWeight:
                                                      FontWeight.bold) ??
                                              'default'),
                                      value: list['permit_id'],
                                    );
                                  },
                                ).toList(),
                                onChanged: (value) {
                                  setState(() {
                                    categorypermit = value;
                                    print(categorypermit);
                                  });
                                }),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Tanggal Mulai:",
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Richard-Samuels',
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        addHorizontalSpace(5),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.55,
                          // color: Colors.black,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white70,
                              ),
                              child: Text(
                                getDateStart(),
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Richard-Samuels',
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () async {
                                final initialDate = DateTime.now();
                                final newDateStart = await showDatePicker(
                                  context: context,
                                  initialDate: initialDate,
                                  firstDate: DateTime(DateTime.now().year - 2),
                                  lastDate: DateTime(DateTime.now().year + 1),
                                  selectableDayPredicate: (date) {
                                    // Disable weekend days to select from the calendar
                                    if (date.weekday == 7) {
                                      return false;
                                    }

                                    return true;
                                  },
                                );

                                if (newDateStart == null) return;
                                setState(() => datestart = newDateStart);
                              }),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Text(
                          "Tanggal Akhir:",
                          style: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Richard-Samuels',
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                        addHorizontalSpace(5),
                        Container(
                          width: MediaQuery.of(context).size.width * 0.55,
                          // color: Colors.black,
                          child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                primary: Colors.white70,
                              ),
                              child: Text(
                                getDateEnd(),
                                style: TextStyle(
                                    fontSize: 12,
                                    fontFamily: 'Richard-Samuels',
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                              onPressed: () async {
                                final initialDate = DateTime.now();
                                final newDateEnd = await showDatePicker(
                                  context: context,
                                  initialDate: initialDate,
                                  firstDate: DateTime(DateTime.now().year - 2),
                                  lastDate: DateTime(DateTime.now().year + 1),
                                  selectableDayPredicate: (date) {
                                    // Disable weekend days to select from the calendar
                                    if (date.weekday == 7) {
                                      return false;
                                    }

                                    return true;
                                  },
                                );

                                if (newDateEnd == null) return;
                                setState(() => dateend = newDateEnd);
                              }),
                        ),
                      ],
                    ),
                    addVerticalSpace(5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width * 0.25,
                          // color: Colors.black,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.zero,
                                minimumSize: Size.fromHeight(30),
                                primary: Colors.white70,
                                textStyle: TextStyle(fontSize: 10)),
                            onPressed: () {
                              addImage();
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.image,
                                  size: 15,
                                  color: Colors.black,
                                ),
                                addHorizontalSpace(2),
                                Text(
                                  "Add Photo",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontFamily: 'Richard-Samuels',
                                      color: Colors.black,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                        ),
                        addHorizontalSpace(4),
                        Container(
                            // color: Colors.black,
                            width: MediaQuery.of(context).size.width * 0.55,
                            height: 175,
                            child: image != null
                                ? Image.file(
                                    image,
                                    fit: BoxFit.fill,
                                  )
                                : Icon(Icons.image))
                      ],
                    ),
                    Container(
                      child: TextFormField(
                        onChanged: (value) {
                          setState(() {
                            keteranganpermit = value.toString();
                          });
                        },
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Richard-Samuels',
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: const InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          focusedBorder: UnderlineInputBorder(
                            borderSide: BorderSide(color: Colors.black),
                          ),
                          hintStyle: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Richard-Samuels',
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                          labelText: 'Keterangan :',
                          labelStyle: TextStyle(
                              fontSize: 12,
                              fontFamily: 'Richard-Samuels',
                              color: Colors.black,
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    addVerticalSpace(5),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)))),
                            onPressed: () {
                              savepermit();
                            },
                            child: Text("Simpan"))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        height: 35,
        decoration: BoxDecoration(
          color: Color.fromARGB(255, 41, 71, 135),
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(15), topLeft: Radius.circular(15)),
          // boxShadow: [
          //   BoxShadow(color: Colors.black38, spreadRadius: 0, blurRadius: 10),
          // ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(15.0),
            topRight: Radius.circular(15.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => menuDashboard(() {})),
                    (Route<dynamic> route) => false,
                  );
                },
                icon: Icon(
                  Icons.home,
                  color: Color.fromRGBO(169, 181, 207, 100),
                ),
              ),
              addHorizontalSpace(10),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: BoxConstraints(),
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => menuProfil()),
                    (Route<dynamic> route) => false,
                  );
                },
                icon: Icon(
                  Icons.manage_accounts,
                  color: Color.fromRGBO(169, 181, 207, 100),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
