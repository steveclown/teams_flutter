import 'package:flutter/material.dart';
import 'package:teams/widget_functions.dart';
import 'package:intl/intl.dart';
import 'package:full_screen_image/full_screen_image.dart';

import 'dashboard.dart';
import 'environment.dart';
import 'menuProfile.dart';

class Detail extends StatefulWidget {
  List list;
  int index;
  Detail({this.index, this.list});
  @override
  _DetailState createState() => new _DetailState();
}

class _DetailState extends State<Detail> {
  @override
  Widget build(BuildContext context) {
    var day = DateFormat('EEEE').format(
        DateTime.parse(widget.list[widget.index]['employee_attendance_date']));
    var gettime = DateFormat('yyyy-MM-dd HH:mm:ss')
        .parse(widget.list[widget.index]['employee_attendance_log_in_date']);
    var showtime = DateFormat.Hms().format(gettime);
    return new Scaffold(
      appBar: new AppBar(
        title: new Text("Details Absence In"),
        backgroundColor: Color.fromARGB(255, 41, 71, 135),
      ),
      body: new Container(
        // color: Colors.blueAccent,
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height * 0.7,
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: EdgeInsets.all(15),
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15.0),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: new FullScreenWidget(
                          child: Center(
                            child: Hero(
                              tag: "Preview",
                              child: new Image(
                                image: NetworkImage(
                                    '$env/teams/assets/images/attendance/${widget.list[widget.index]['employee_attendance_images']}'),
                                height: 200,
                                width: 200,
                                fit: BoxFit.fill,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 10)),
                      new Text(
                        'Days : $day',
                        style: new TextStyle(fontSize: 15.0),
                      ),
                      new Text(
                        "Date : ${widget.list[widget.index]['employee_attendance_date']}",
                        style: new TextStyle(fontSize: 15.0),
                      ),
                      new Text(
                        "Time : $showtime",
                        style: new TextStyle(fontSize: 15.0),
                      ),
                      new Text(
                        "IP : ${widget.list[widget.index]['machine_ip_address']}",
                        style: new TextStyle(fontSize: 15.0),
                      ),
                      new Text(
                        "Location : ${widget.list[widget.index]['employee_attendance_location_in']}",
                        style: new TextStyle(fontSize: 15.0),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
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
