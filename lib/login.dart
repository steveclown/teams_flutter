import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'dashboard.dart';

import 'package:fluttertoast/fluttertoast.dart';

import 'environment.dart';

void mainLogin() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Login(),
    theme: ThemeData(),
  ));
}

class Login extends StatefulWidget {
  @override
  _LoginState createState() => _LoginState();
}

enum LoginStatus { notSignIn, signIn }

class _LoginState extends State<Login> {
  LoginStatus _loginStatus = LoginStatus.notSignIn;

  String username = "", password = "";
  final _key = new GlobalKey<FormState>();

  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      login();
    }
  }

  login() async {
    var url = Uri.parse("$env/teams/login.php");
    final response = await http.post(url, headers: {
      "Access-Control-Allow-Origin": "*",
    }, body: {
      "username": username,
      "password": password
    });
    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];
    if (value == 1) {
      String region_id = data['region_id'];
      String branch_id = data['branch_id'];
      String location_id = data['location_id'];
      String division_id = data['division_id'];
      String department_id = data['department_id'];
      String section_id = data['section_id'];
      String unit_id = data['unit_id'];
      int employee_id = int.parse(data['employee_id']);
      String shift_id = data['shift_id'];
      String employee_shift_id = data['employee_shift_id'];
      String usernameAPI = data['username'];
      String avatar = data['avatar'];
      int payroll_employee_level = int.parse(data['payroll_employee_level']);
      String department_code = data['department_code'];
      String employee_rfid_code = data['employee_rfid_code'];
      setState(() {
        _loginStatus = LoginStatus.signIn;
        savePref(
            value,
            region_id,
            branch_id,
            location_id,
            division_id,
            department_id,
            section_id,
            unit_id,
            employee_id,
            shift_id,
            employee_shift_id,
            usernameAPI,
            password,
            avatar,
            payroll_employee_level,
            department_code,
            employee_rfid_code);
      });
      print("value : $value");
      print("region_id : $region_id");
      print("branch_id : $branch_id");
      print("location_id : $location_id");
      print("division_id : $division_id");
      print("department_id : $department_id");
      print("section_id : $section_id");
      print("unit_id : $unit_id");
      print("employee_id : $employee_id");
      print("shift_id : $shift_id");
      print("employee_shift_id : $employee_shift_id");
      print("usernameAPI : $usernameAPI");
      print("Password : $password");
      print("avatar : $avatar");
      print("payroll_employee_level : $payroll_employee_level");
      print("department_code : $department_code");
      print("employee_rfid_code : $employee_rfid_code");

      print(pesan);
      print(username);
      print(password);
      print(pesan);
    } else {
      print(username);
      print(password);
      print(value);
      print(pesan);
      return Fluttertoast.showToast(
          msg: "Username or Password not match",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  savePref(
    int value,
    String region_id,
    String branch_id,
    String location_id,
    String division_id,
    String department_id,
    String section_id,
    String unit_id,
    int employee_id,
    String shift_id,
    String employee_shift_id,
    String username,
    String password,
    String avatar,
    int payroll_employee_level,
    String department_code,
    String employee_rfid_code,
  ) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      if (value != null) {
        preferences.setInt("value", value);
      }
      if (region_id != null) {
        preferences.setString("region_id", region_id);
      }
      if (branch_id != null) {
        preferences.setString("branch_id", branch_id);
      }
      if (location_id != null) {
        preferences.setString("location_id", location_id);
      }
      if (division_id != null) {
        preferences.setString("division_id", division_id);
      }
      if (department_id != null) {
        preferences.setString("department_id", department_id);
      }
      if (section_id != null) {
        preferences.setString("section_id", section_id);
      }
      if (unit_id != null) {
        preferences.setString("unit_id", unit_id);
      }
      if (employee_id != null) {
        preferences.setInt("employee_id", employee_id);
      }
      if (shift_id != null) {
        preferences.setString("shift_id", shift_id);
      }
      if (employee_shift_id != null) {
        preferences.setString("employee_shift_id", employee_shift_id);
      }
      if (username != null) {
        preferences.setString("username", username);
      }
      if (password != null) {
        preferences.setString("password", password);
      }
      if (avatar != null) {
        preferences.setString("avatar", avatar);
      }
      if (payroll_employee_level != null) {
        preferences.setInt("payroll_employee_level", payroll_employee_level);
      }
      if (department_code != null) {
        preferences.setString("department_code", department_code);
      }
      if (department_code != null) {
        preferences.setString("employee_rfid_code", employee_rfid_code);
      }
      preferences.commit();
    });
  }

// Function SharedPreferences Get Value
  var value;
  getPref() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      value = preferences.getInt("value");

      _loginStatus = value == 1 ? LoginStatus.signIn : LoginStatus.notSignIn;
    });
  }

// Function SignOut and set value = 0
  signOut() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      preferences.setInt("value", 0);
      preferences.commit();
      _loginStatus = LoginStatus.notSignIn;
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
    switch (_loginStatus) {
      case LoginStatus.notSignIn:
        return Scaffold(
          body: Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/icon/background/bg-39.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: Form(
                  key: _key,
                  child: ListView(
                    padding: EdgeInsets.all(50.0),
                    children: <Widget>[
                      Padding(padding: EdgeInsets.fromLTRB(0, 90, 0, 0)),
                      // Image(
                      //     image: NetworkImage(
                      //         '$env/teams/assets/images/logo.jpg')),
                      Text(
                        '''Welcome To Teams''',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 45,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Montserrat',
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 10.0)),
                      TextFormField(
                        validator: (e) {
                          if (e.isEmpty) {
                            return "Please insert username";
                          }
                        },
                        onSaved: (e) => username = e,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 2.5),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          labelText: 'username',
                          border: OutlineInputBorder(
                              borderSide: BorderSide(color: Colors.white)),
                          suffixIcon: Icon(
                            Icons.people,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 10.0)),
                      TextFormField(
                        validator: (e) {
                          if (e.isEmpty) {
                            return "Please insert password";
                          }
                        },
                        obscureText: _secureText,
                        onSaved: (e) => password = e,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                BorderSide(color: Colors.white, width: 2.5),
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                          labelStyle: TextStyle(
                            color: Colors.white,
                          ),
                          labelText: 'password',
                          border: OutlineInputBorder(),
                          suffixIcon: IconButton(
                            onPressed: showHide,
                            icon: Icon(_secureText
                                ? Icons.visibility_off
                                : Icons.visibility),
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(padding: EdgeInsets.only(top: 10.0)),
                      RaisedButton(
                        onPressed: () {
                          // print(username);
                          check();
                        },
                        color: Colors.white,
                        shape: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white, width: 2.5),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(0, 15, 0, 15),
                          child: Text(
                            "Login",
                            style: TextStyle(
                              fontFamily: 'montserrat',
                              fontSize: 20,
                              color: Colors.black,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      // OutlinedButton(
                      //   onPressed: () {
                      //     check();
                      //   },
                      //   child: Text("Login"),
                      //   style: OutlinedButton.styleFrom(
                      //       side: BorderSide(color: Colors.white, width: 2.0),
                      //       primary: Colors.white,
                      //       minimumSize: Size(150.0, 40.0)),
                      // ),
                      // OutlinedButton(
                      //   onPressed: () {
                      //     Navigator.of(context).push(
                      //         MaterialPageRoute(builder: (context) => Register()));
                      //   },
                      //   child: Text("Create a new account, in here"),
                      //   style: OutlinedButton.styleFrom(
                      //       side: BorderSide(color: Colors.white, width: 2.0),
                      //       primary: Colors.white,
                      //       minimumSize: Size(150.0, 40.0)),
                      // ),
                    ],
                  ),
                ),
              )),
        );
        break;
      case LoginStatus.signIn:
        return menuDashboard(signOut);
        break;
    }
  }
}

class Register extends StatefulWidget {
  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  String username, password, nama;
  final _key = new GlobalKey<FormState>();

  bool _secureText = true;

  showHide() {
    setState(() {
      _secureText = !_secureText;
    });
  }

  check() {
    final form = _key.currentState;
    if (form.validate()) {
      form.save();
      save();
    }
  }

  save() async {
    var url = Uri.parse("$env/teams/register.php");
    final response = await http.post(url, headers: {
      "Access-Control-Allow-Origin": "*",
    }, body: {
      "nama": nama,
      "username": username,
      "password": password
    });
    final data = jsonDecode(response.body);
    int value = data['value'];
    String pesan = data['message'];
    if (value == 1) {
      setState(() {
        Navigator.pop(context);
      });
    } else {
      print(pesan);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Register"),
      ),
      body: Form(
        key: _key,
        child: ListView(
          padding: EdgeInsets.all(16.0),
          children: <Widget>[
            TextFormField(
              validator: (e) {
                if (e.isEmpty) {
                  return "Please insert fullname";
                }
              },
              onSaved: (e) => nama = e,
              decoration: InputDecoration(labelText: "Nama Lengkap"),
            ),
            TextFormField(
              validator: (e) {
                if (e.isEmpty) {
                  return "Please insert username";
                }
              },
              onSaved: (e) => username = e,
              decoration: InputDecoration(labelText: "username"),
            ),
            TextFormField(
              obscureText: _secureText,
              onSaved: (e) => password = e,
              decoration: InputDecoration(
                hintText: "Password",
                labelText: "Password",
                suffixIcon: IconButton(
                  onPressed: showHide,
                  icon: Icon(
                      _secureText ? Icons.visibility_off : Icons.visibility),
                ),
              ),
            ),
            OutlinedButton(
              onPressed: () {
                check();
              },
              child: Text("Register"),
              style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white, width: 2.0),
                  primary: Colors.white,
                  minimumSize: Size(150.0, 40.0)),
            ),
          ],
        ),
      ),
    );
  }
}
