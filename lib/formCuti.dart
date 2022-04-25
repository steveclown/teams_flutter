import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:teams/widget_functions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get_connect/http/src/utils/utils.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard.dart';
import 'environment.dart';
import 'menuCuti.dart';
import 'menuProfile.dart';

class formCuti extends StatefulWidget {
  @override
  State<formCuti> createState() => _formCutiState();
}

class _formCutiState extends State<formCuti> {
  List datacategory = List();
  List dataquota = List();
  int selisih;
  int bottomIndex = 0;
  int isrow;
  int employee_leave_id;
  int employee_id;
  String employee_leave_description = "";
  String employee_leave_due_date = "";
  int employee_leave_status;
  String keterangan = "";
  String category;
  int quota;
  String strdatestart = "";
  String strdateend = "";
  DateTime datestart;
  DateTime dateend;
  String region_id = "";
  String branch_id = "";
  String location_id = "";
  String division_id = "";
  String department_id = "";
  String section_id = "";

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

  Future getCategoryLeave() async {
    var url = Uri.parse("$env/teams/getcategoryleave.php");
    final response = await http.get(url, headers: {
      "Accept": "application/json",
      "Access-Control-Allow-Origin": "*",
    });
    var data = jsonDecode(response.body);
    setState(() {
      datacategory = data;
    });
    print(data);
  }

  Future getQuotaLeave() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    int id = preferences.getInt("employee_id");
    var url = Uri.parse("$env/teams/getquotaleave.php");
    final response = await http.post(url, headers: {
      "Accept": "application/json",
      "Access-Control-Allow-Origin": "*",
    }, body: {
      "employee_id": '$id'
    });
    var data = jsonDecode(response.body);
    setState(() {
      dataquota = data;
      quota = int.parse(data[0]['hro_employee_leave_quota_total']);
    });
    print(data);
    print(id);
    print(quota);
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

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      region_id = preferences.getString("region_id");
      branch_id = preferences.getString("branch_id");
      location_id = preferences.getString("location_id");
      division_id = preferences.getString("division_id");
      department_id = preferences.getString("department_id");
      section_id = preferences.getString("section_id");
      employee_id = preferences.getInt("employee_id");
      isrow = preferences.getInt("isrow");
      employee_leave_id = preferences.getInt("employee_leave_id");
      employee_leave_description =
          preferences.getString("employee_leave_description");
      employee_leave_due_date =
          preferences.getString("employee_leave_due_date");
      employee_leave_status = preferences.getInt("employee_leave_status");
    });
  }

  save() async {
    var periode = DateFormat('yyyyMM').format(DateTime.now());
    var days = DateFormat('dd').format(DateTime.now());
    var url = Uri.parse("$env/teams/insertleave.php");
    final response = await http.post(url, headers: {
      "Access-Control-Allow-Origin": "*",
    }, body: {
      "region_id": region_id,
      "branch_id": branch_id,
      "location_id": location_id,
      "division_id": division_id,
      "department_id": department_id,
      "section_id": section_id,
      "employee_id": employee_id.toString(),
      "annual_leave_id": category,
      "employee_leave_start_date": strdatestart,
      "employee_leave_due_date": strdateend,
      "employee_leave_description": keterangan,
      "periode": periode,
      "days": days,
    });
    final data = jsonDecode(response.body);
    int values = data['values'];
    String pesan = data['message'];
    int emp = employee_id;
    String cat = category;
    String tglstart = strdatestart;
    String tglend = strdateend;
    String ket = keterangan;

    print(pesan);
    print(emp);
    print(cat);
    print(tglstart);
    print(tglend);
    print(ket);
    if (values == 1) {
      Fluttertoast.showToast(
          msg: "Permintaan Cuti Berhasil",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Color.fromARGB(255, 42, 46, 147),
          textColor: Colors.white,
          fontSize: 16.0);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => dataCuti()),
        (Route<dynamic> route) => false,
      );
    } else {
      return Fluttertoast.showToast(
          msg: "Permintaan Cuti Gagal",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 5,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getPref();
    getCategoryLeave();
    getQuotaLeave();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 41, 71, 135),
        title: Text(
          "Form Leave",
          style:
              TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.5,
        child: Card(
          color: Color.fromARGB(255, 230, 243, 252),
          elevation: 10,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // new Row(
                //   children: [Text(quota)],
                // ),
                new Row(
                  children: [
                    (() {
                      if (quota != null) {
                        return Text('Sisa Kuota : $quota');
                      } else {
                        return Text("");
                      }
                    }())
                  ],
                ),
                new Row(
                  children: [
                    Text(
                      "Tanggal Mulai:",
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Color.fromARGB(255, 41, 71, 135),
                          fontWeight: FontWeight.bold),
                    ),
                    addHorizontalSpace(24),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.52,
                      // color: Colors.black,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white70,
                          ),
                          child: Text(
                            getDateStart(),
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                color: Color.fromARGB(255, 41, 71, 135),
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
                addVerticalSpace(5),
                new Row(
                  children: [
                    Text(
                      "Tanggal Berakhir:",
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Color.fromARGB(255, 41, 71, 135),
                          fontWeight: FontWeight.bold),
                    ),
                    addHorizontalSpace(5),
                    Container(
                      // color: Colors.black,
                      width: MediaQuery.of(context).size.width * 0.52,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            primary: Colors.white70,
                          ),
                          child: Text(
                            getDateEnd(),
                            style: TextStyle(
                                fontFamily: 'Montserrat',
                                fontSize: 15,
                                color: Color.fromARGB(255, 41, 71, 135),
                                fontWeight: FontWeight.bold),
                          ),
                          onPressed: () async {
                            final initialDate = DateTime.now();
                            final newDateEnd = await showDatePicker(
                              context: context,
                              initialDate: initialDate,
                              firstDate: DateTime(DateTime.now().year - 5),
                              lastDate: DateTime(DateTime.now().year + 5),
                              selectableDayPredicate: (date) {
                                // Disable weekend days to select from the calendar
                                if (date.weekday == 7) {
                                  return false;
                                }

                                return true;
                              },
                            );

                            if (newDateEnd == null) {
                              return;
                            } else {
                              DateTime newDateStart =
                                  DateTime.parse('$strdatestart');
                              final tglawal = DateTime(newDateStart.year,
                                  newDateStart.month, newDateStart.day);
                              final tglakhir = DateTime(newDateEnd.year,
                                  newDateEnd.month, newDateEnd.day);
                              int a = tglakhir.difference(tglawal).inDays;

                              if (a > 3) {
                                return setState(() {
                                  dateend = null;
                                  strdateend = null;
                                  print("Lebih dari 3hari");
                                  Fluttertoast.showToast(
                                      msg: "Batas Cuti 3hari",
                                      toastLength: Toast.LENGTH_SHORT,
                                      gravity: ToastGravity.CENTER,
                                      timeInSecForIosWeb: 5,
                                      backgroundColor: Colors.red,
                                      textColor: Colors.white,
                                      fontSize: 16.0);
                                });
                              } else {
                                return setState(() {
                                  dateend = newDateEnd;
                                  selisih = tglakhir.difference(tglawal).inDays;
                                  print(tglawal);
                                  print(tglakhir);
                                  print(selisih);
                                });
                              }
                            }

                            // if (newDateEnd == null) return;
                            // setState(() {
                            //   dateend = newDateEnd;
                            //   selisih = tglakhir.difference(tglawal).inDays;
                            // });

                            // print(tglawal);
                            // print(tglakhir);
                            // print(selisih);
                          }),
                    ),
                  ],
                ),
                addVerticalSpace(5),
                Row(
                  children: [
                    Text(
                      "Pilih Kategori :",
                      style: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Color.fromARGB(255, 41, 71, 135),
                          fontWeight: FontWeight.bold),
                    ),
                    addHorizontalSpace(31),
                    Container(
                      width: MediaQuery.of(context).size.width * 0.50,
                      child: Center(
                        child: DropdownButton(
                            style: TextStyle(
                              color: Color.fromARGB(255, 41, 71, 135),
                            ),
                            value: category,
                            hint: Text(
                              "Select Category",
                              style: TextStyle(
                                  fontFamily: 'Montserrat',
                                  color: Color.fromARGB(255, 41, 71, 135),
                                  fontWeight: FontWeight.bold),
                            ),
                            items: datacategory.map(
                              (list) {
                                return DropdownMenuItem(
                                  child: Text(list['annual_leave_name']),
                                  value: list['annual_leave_id'],
                                );
                              },
                            ).toList(),
                            onChanged: (value) {
                              setState(() {
                                category = value;
                                print(category);
                              });
                            }),
                      ),
                    )
                  ],
                ),
                Container(
                  child: TextFormField(
                    onChanged: (value) {
                      setState(() {
                        keterangan = value.toString();
                      });
                    },
                    style: TextStyle(
                      color: Color.fromARGB(255, 41, 71, 135),
                    ),
                    decoration: const InputDecoration(
                      hintStyle: TextStyle(
                          fontFamily: 'Montserrat',
                          color: Color.fromARGB(255, 41, 71, 135),
                          fontWeight: FontWeight.bold),
                      border: UnderlineInputBorder(),
                      labelText: 'Keterangan :',
                    ),
                  ),
                ),
                addVerticalSpace(10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    (() {
                      if (quota == 0) {
                        return ElevatedButton(
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.transparent),
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)))),
                            onPressed: () {
                              return Fluttertoast.showToast(
                                  msg: "Kuota Cuti Sudah Habis",
                                  toastLength: Toast.LENGTH_SHORT,
                                  gravity: ToastGravity.CENTER,
                                  timeInSecForIosWeb: 5,
                                  backgroundColor:
                                      Color.fromARGB(255, 42, 46, 147),
                                  textColor: Colors.white,
                                  fontSize: 16.0);
                            },
                            child: Text(""));
                      } else {
                        return ElevatedButton(
                            style: ButtonStyle(
                                shape: MaterialStateProperty.all(
                                    RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(15)))),
                            onPressed: () {
                              // int totaldays =
                              //     dateend.difference(datestart).inDays;
                              // print(totaldays);
                              save();
                            },
                            child: Text("Simpan"));
                      }
                    }())
                  ],
                )
              ],
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
