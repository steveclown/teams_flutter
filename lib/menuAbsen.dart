import 'package:flutter/material.dart';
import 'package:teams/menuProfile.dart';
import 'package:teams/widget_functions.dart';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'dashboard.dart';
import 'detailAbsen.dart';
import 'environment.dart';
import 'menuCuti.dart';

class dataAbsen extends StatefulWidget {
  @override
  State<dataAbsen> createState() => _dataAbsenState();
}

class _dataAbsenState extends State<dataAbsen> {
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
      department_code = "",
      employee_rfid_code = "",
      wifiIP = "",
      strimg = "",
      substrimg = "",
      substrimg2 = "",
      tostrimg = "";
  int value = 0;
  int employee_id;

  Future<List> getData() async {
    var url = Uri.parse("$env/teams/getdata.php");
    final response = await http.post(url, headers: {
      "Access-Control-Allow-Origin": "*",
    }, body: {
      "employee_id": employee_id.toString()
    });
    return jsonDecode(response.body);
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
      unit_id = preferences.getString("unit_id");
      employee_id = preferences.getInt("employee_id");
      shift_id = preferences.getString("shift_id");
      employee_shift_id = preferences.getString("employee_shift_id");
      username = preferences.getString("username");
      department_code = preferences.getString("department_code");
      employee_rfid_code = preferences.getString("employee_rfid_code");
      value = preferences.getInt("value");
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
    return new Scaffold(
      appBar: new AppBar(
        backgroundColor: Color.fromARGB(255, 41, 71, 135),
        title: Text(
          "Riwayat Absen Masuk",
          style:
              TextStyle(fontFamily: 'Montserrat', fontWeight: FontWeight.bold),
        ),
      ),
      body: new FutureBuilder<List>(
        future: getData(),
        builder: (context, snapshot) {
          if (snapshot.hasError) print(snapshot.error);

          return snapshot.hasData
              ? new ItemList(list: snapshot.data)
              : new Center(
                  child: new CircularProgressIndicator(),
                );
        },
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
          padding: const EdgeInsets.fromLTRB(10, 3, 10, 3),
          child: new GestureDetector(
            onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new Detail(
                      list: list,
                      index: i,
                    ))),
            child: new Card(
              color: Colors.white,
              elevation: 10,
              shadowColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15.0),
              ),
              child: new ListTile(
                title: new Text(
                    DateFormat('EEEE', 'id_ID').format(
                        DateTime.parse(list[i]['employee_attendance_date'])),
                    style: TextStyle(
                      fontFamily: 'Montserrat',
                      fontWeight: FontWeight.bold,
                    )),
                leading:
                    new Image(image: AssetImage("assets/icon/06/icon-19.png")),
                subtitle: new Text(
                  list[i]['employee_attendance_date'],
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
