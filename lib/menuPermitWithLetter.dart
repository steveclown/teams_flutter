import 'package:convex_bottom_bar/convex_bottom_bar.dart';
import 'package:flutter/material.dart';
import 'package:teams/formCuti.dart';
import 'package:teams/formPermit.dart';
import 'package:teams/formPermitWithLetter.dart';
import 'package:teams/widget_functions.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:rflutter_alert/rflutter_alert.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard.dart';
import 'environment.dart';
import 'menuCuti.dart';
import 'menuProfile.dart';

class dataIjinWithLetter extends StatefulWidget {
  @override
  State<dataIjinWithLetter> createState() => _dataIjinWithLetterState();
}

class _dataIjinWithLetterState extends State<dataIjinWithLetter> {
  int employee_id;
  int bottomIndex = 0;

  Future<List> getDataPermit() async {
    var url = Uri.parse("$env/teams/getdatapermit.php");
    final response = await http.post(url, headers: {
      "Accept": "application/json",
      "Access-Control-Allow-Origin": "*",
    }, body: {
      "employee_id": employee_id.toString()
    });
    var data = jsonDecode(response.body);
    print("Data Permit");
    print(data);
    return jsonDecode(response.body);
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
      employee_id = preferences.getInt("employee_id");
    });
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
          "Permit With Letter",
          style:
              TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        // color: Colors.black,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(10, 10, 10, 25),
          child: Card(
            color: Color.fromARGB(255, 230, 243, 252),
            elevation: 10,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0)),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "History",
                    style: TextStyle(
                        fontSize: 15,
                        fontFamily: 'Richard-Samuels',
                        color: Colors.black,
                        fontWeight: FontWeight.bold),
                  ),
                  Divider(),
                  Container(
                    // color: Colors.black,
                    width: MediaQuery.of(context).size.width,
                    height: MediaQuery.of(context).size.height * 0.62,
                    child: FutureBuilder<List>(
                      future: getDataPermit(),
                      builder: (context, snapshot) {
                        if (snapshot.hasError) print(snapshot.error);

                        return snapshot.hasData
                            ? new ItemList(list: snapshot.data)
                            : new Center(child: CircularProgressIndicator());
                      },
                    ),
                  ),
                  addVerticalSpace(1),
                  Container(
                    width: MediaQuery.of(context).size.width,
                    height: 30,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        FloatingActionButton(
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => formPermit()));
                          },
                          child: const Icon(Icons.add),
                        ),
                      ],
                    ),
                  ),
                ],
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
                        '${(list[i]['employee_permit_start_date'])} s/d ${(list[i]['employee_permit_end_date'])}',
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
                        (list[i]['employee_permit_description']),
                        style: TextStyle(
                          fontSize: 15,
                          fontFamily: 'Richard-Samuels',
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                      addVerticalSpace(8),
                      new Text(
                        'Alasan : ${(list[i]['employee_permit_remark'])}',
                        style: TextStyle(
                          fontSize: 12,
                          fontFamily: 'Richard-Samuels',
                          // fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: (() {
                    if ((list[i]['employee_attendance_date_status']) == "0") {
                      return Icon(Icons.pending);
                    } else if ((list[i]['employee_attendance_date_status']) ==
                        "1") {
                      return Icon(Icons.highlight_off, color: Colors.red);
                    } else if ((list[i]['employee_attendance_date_status']) ==
                        "2") {
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
