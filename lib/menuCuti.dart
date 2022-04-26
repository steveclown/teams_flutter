import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:teams/formCuti.dart';
import 'package:teams/widget_functions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard.dart';
import 'environment.dart';
import 'menuProfile.dart';

class dataCuti extends StatefulWidget {
  @override
  State<dataCuti> createState() => _dataCutiState();
}

class _dataCutiState extends State<dataCuti> {
  int bottomIndex = 0;
  int employee_id;

  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      employee_id = preferences.getInt("employee_id");
    });
  }

  Future<List> getLastDataLeave() async {
    var url = Uri.parse("$env/teams/getlastdataleave.php");
    final response = await http.post(url, headers: {
      "Access-Control-Allow-Origin": "*",
    }, body: {
      "employee_id": employee_id.toString()
    });
    return jsonDecode(response.body);
  }

  Future<List> getDataLeave() async {
    var url = Uri.parse("$env/teams/getdataleave.php");
    final response = await http.post(url, headers: {
      "Accept": "application/json",
      "Access-Control-Allow-Origin": "*",
    }, body: {
      "employee_id": employee_id.toString()
    });
    var data = jsonDecode(response.body);
    print("Data Leave");
    print(data);
    return jsonDecode(response.body);
  }

  // idicatorstatus() {
  //   if (employee_leave_status == 0) {
  //     return Icon(Icons.pending);
  //   } else if (employee_leave_status == 1) {
  //     return Icon(Icons.highlight_off, color: Colors.red);
  //   } else if (employee_leave_status == 2) {
  //     return Icon(Icons.check_circle, color: Colors.green);
  //   }
  // }

  // tblpengajuan() {
  //   if (isrow == 1) {
  //     return ListTile(
  //       visualDensity: VisualDensity(horizontal: 0, vertical: -4),
  //       contentPadding: EdgeInsets.zero,
  //       title: Text(
  //         "$employee_leave_start_date s/d $employee_leave_due_date",
  //         style: TextStyle(
  //             fontSize: 12,
  //             fontFamily: 'Montserrat',
  //             color: Colors.black,
  //             fontWeight: FontWeight.bold),
  //       ),
  //       subtitle: Text(
  //         employee_leave_description,
  //         style: TextStyle(
  //             fontSize: 12,
  //             fontFamily: 'Montserrat',
  //             color: Colors.black,
  //             fontWeight: FontWeight.bold),
  //       ),
  //       trailing: idicatorstatus(),
  //     );
  //   } else {
  //     return Padding(
  //       padding: const EdgeInsets.only(top: 30),
  //       child: Center(
  //           child: Text(
  //         "TIDAK ADA PENGAJUAN",
  //         style: TextStyle(
  //             fontFamily: 'Montserrat',
  //             color: Colors.black,
  //             fontWeight: FontWeight.bold),
  //       )),
  //     );
  //   }
  // }

  // tblhapus() {
  //   if (employee_leave_status == 0) {
  //     return ElevatedButton(
  //         onPressed: () {
  //           deleteDataLeave();
  //         },
  //         child: Text("Hapus"));
  //   } else if (employee_leave_status == 1) {
  //     return ElevatedButton(
  //         onPressed: () {
  //           deleteDataLeave();
  //         },
  //         child: Text("Hapus"));
  //   } else if (employee_leave_status == 2) {
  //     return Text("");
  //   } else {
  //     return Text("");
  //   }
  // }

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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(
        backgroundColor: Color.fromARGB(255, 41, 71, 135),
        title: Text(
          "Cuti",
          style:
              TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          new Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.28,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Card(
                color: Color.fromARGB(255, 230, 243, 252),
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: new Padding(
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Pengajuan",
                        style: TextStyle(
                            fontSize: 15,
                            fontFamily: 'Richard-Samuels',
                            color: Colors.black,
                            fontWeight: FontWeight.bold),
                      ),
                      Divider(),
                      Container(
                        // color: Colors.red,
                        width: MediaQuery.of(context).size.width,
                        height: 110,
                        child: FutureBuilder<List>(
                          future: getLastDataLeave(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) print(snapshot.error);

                            return snapshot.hasData
                                ? new ItemListLast(list: snapshot.data)
                                : new Center(
                                    child: CircularProgressIndicator());
                          },
                        ),
                      ),
                      // Row(
                      //   mainAxisAlignment: MainAxisAlignment.end,
                      //   crossAxisAlignment: CrossAxisAlignment.end,
                      //   children: [tblhapus()],
                      // )
                    ],
                  ),
                ),
              ),
            ),
          ),
          new Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.51,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: new Card(
                color: Color.fromARGB(255, 230, 243, 252),
                elevation: 10,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15.0)),
                child: new Padding(
                  padding: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.zero,
                            child: Text(
                              "Riwayat",
                              style: TextStyle(
                                  fontSize: 15,
                                  fontFamily: 'Richard-Samuels',
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          )
                        ],
                      ),
                      Divider(),
                      Container(
                        // color: Colors.red,
                        width: MediaQuery.of(context).size.width,
                        height: 209,
                        child: FutureBuilder<List>(
                          future: getDataLeave(),
                          builder: (context, snapshot) {
                            if (snapshot.hasError) print(snapshot.error);

                            return snapshot.hasData
                                ? new ItemList(list: snapshot.data)
                                : new Center(
                                    child: CircularProgressIndicator());
                          },
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 4,
                        ),
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          height: 35,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              FloatingActionButton(
                                onPressed: () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => formCuti()));
                                },
                                child: const Icon(Icons.add),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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

class ItemListLast extends StatelessWidget {
  final List list;
  ItemListLast({this.list});

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: list == null ? 0 : list.length,
      itemBuilder: (context, i) {
        return new Container(
          child: Column(
            children: [
              new ListTile(
                horizontalTitleGap: 0,
                minLeadingWidth: 0,
                contentPadding: EdgeInsets.zero,
                isThreeLine: true,
                title: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    new Text(
                      '${(list[i]['employee_leave_start_date'])} s/d ${(list[i]['employee_leave_due_date'])}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Richard-Samuels',
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    addVerticalSpace(5)
                  ],
                ),
                subtitle: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    new Text(
                      (list[i]['employee_leave_description']),
                      style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Richard-Samuels',
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    addVerticalSpace(8),
                    new Text(
                      'Alasan : ${(list[i]['employee_leave_remark'])}',
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Richard-Samuels',
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                trailing: new GestureDetector(
                    onDoubleTap: () => print("double tap"),
                    onLongPress: () async {
                      var url = Uri.parse("$env/teams/deletelastdataleave.php");
                      final response = await http.post(url, headers: {
                        "Access-Control-Allow-Origin": "*",
                      }, body: {
                        "employee_id": (list[i]['employee_id']),
                        "employee_leave_id": (list[i]['employee_leave_id']),
                      });
                      final data = jsonDecode(response.body);
                      int valdel = data['valdel'];
                      String pesan = data['message'];
                      print(valdel);
                      print(pesan);
                      if (valdel == 1) {
                        Fluttertoast.showToast(
                            msg: "Pengajuan Berhasil dihapus",
                            toastLength: Toast.LENGTH_SHORT,
                            gravity: ToastGravity.CENTER,
                            timeInSecForIosWeb: 10,
                            backgroundColor: Color.fromARGB(255, 42, 46, 147),
                            textColor: Colors.white,
                            fontSize: 16.0);
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => dataCuti()),
                          (Route<dynamic> route) => false,
                        );
                      }
                    },
                    child: (() {
                      if ((list[i]['employee_leave_status']) == "0") {
                        return Icon(Icons.pending);
                      } else if ((list[i]['employee_leave_status']) == "1") {
                        return Icon(Icons.highlight_off, color: Colors.red);
                      } else if ((list[i]['employee_leave_status']) == "2") {
                        return Icon(Icons.check_circle, color: Colors.green);
                      }
                    }())),
              ),
            ],
          ),
        );
      },
    );
  }
}

class ItemList extends StatelessWidget {
  final List list;
  ItemList({this.list});

  @override
  Widget build(BuildContext context) {
    return new ListView.builder(
      itemCount: list == null ? 0 : list.length,
      itemBuilder: (context, i) {
        return new Container(
          child: Column(
            children: [
              new ListTile(
                  horizontalTitleGap: 0,
                  minLeadingWidth: 0,
                  contentPadding: EdgeInsets.zero,
                  isThreeLine: true,
                  title: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Text(
                        '${(list[i]['employee_leave_start_date'])} s/d ${(list[i]['employee_leave_due_date'])}',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Richard-Samuels',
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      addVerticalSpace(5)
                    ],
                  ),
                  subtitle: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      new Text(
                        (list[i]['employee_leave_description']),
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Richard-Samuels',
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      addVerticalSpace(8),
                      new Text(
                        'Alasan : ${(list[i]['employee_leave_remark'])}',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Richard-Samuels',
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: (() {
                    if ((list[i]['employee_leave_status']) == "0") {
                      return Icon(Icons.pending);
                    } else if ((list[i]['employee_leave_status']) == "1") {
                      return Icon(Icons.highlight_off, color: Colors.red);
                    } else if ((list[i]['employee_leave_status']) == "2") {
                      return Icon(Icons.check_circle, color: Colors.green);
                    }
                  }())),
              Divider()
            ],
          ),
        );
      },
    );
  }
}
