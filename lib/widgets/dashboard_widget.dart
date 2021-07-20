// import 'dart:math';

import "package:flutter/material.dart";
// import "./signup_widget.dart";
import "./login_widget.dart";
// import 'dart:io' as IO;
import "package:flutter_icons/flutter_icons.dart";
import 'package:fluttertoast/fluttertoast.dart';
import "dart:convert";
// import 'dart:typed_data';
import "package:shared_preferences/shared_preferences.dart";
import "package:http/http.dart" as http;

var userData;

class DashboardWidget extends StatefulWidget {
  @override
  _DashboardWidgetState createState() => _DashboardWidgetState();
}

class _DashboardWidgetState extends State<DashboardWidget> {
  var firstName;
  var lastName;
  var email;
  var mobileNo;
  var location;
  var allDeals = [];
  var previousRedeems = [];
  var filteredDeals = [];
  bool filterStatus = false;

  Future getAllDeals() async {
    var dealUrl = Uri.parse(
        "https://petbottle-project-default-rtdb.firebaseio.com/managerdeals.json");

    var allEmailsResult = await http.get(dealUrl);
    Map body = json.decode(allEmailsResult.body);
    if (body.runtimeType != Null) {
      print("All Deals: " + body.toString());
      var arr = [];
      body.forEach((key, value) {
        if (value['deals'] != null) {
          List val = value['deals'];
          arr.addAll(val);
        }
      });
      print("Runtime Type");
      setState(() {
        allDeals = arr;
      });
    }
  }

  List<String> productsSubtitles = ["KFC", "Macdonald", "Starbucks"];

  _DashboardWidgetState() {
    handleData().whenComplete(() => print("abc"));
  }

  Future handleData() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    var dataId = preference.getString('dataId');

    var url2 = Uri.parse(
        "https://petbottle-project-default-rtdb.firebaseio.com/usersdata/$dataId.json");

    var result2 = await http.get(url2);

    var body = await json.decode(result2.body);
    if (body != null) {
      setState(() {
        userData = body;
      });
    }
  }

  Future updateData() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    var dataId = preference.getString('dataId');
    print(dataId);
    var url3 = Uri.parse(
        "https://petbottle-project-default-rtdb.firebaseio.com/usersdata/$dataId.json");

    var result3 = await http.patch(url3,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'email': userData['email'],
          'firstName': userData['firstName'],
          'lastName': userData['lastName'],
          'mobileNo': userData['mobileNo']
        }));
    print(json.decode(result3.body));

    if (userData['email'] != email) {}
  }

  void changeEmail() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    var urlForEmail = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:update?key=AIzaSyD6FVCXVR7SqRD2rjavBUAantQxi8Qpz-4");
    var result4 = await http.post(urlForEmail,
        body: json.encode({
          "idToken": preference.getString("idToken").toString(),
          "email": email,
          "returnSecureToken": false
        }));

    print(json.decode(result4.body));
  }

  Future getPreviousRedeems() async {
    final SharedPreferences preference = await SharedPreferences.getInstance();
    var dataId = preference.getString('dataId');

    var url2 = Uri.parse(
        "https://petbottle-project-default-rtdb.firebaseio.com/usersdata/$dataId.json");

    var data = await http.get(url2);
    var redeem = json.decode(data.body)['previousRedeems'];
    if (redeem != null) {
      setState(() {
        previousRedeems = redeem;
      });
    }
  }

  void updateRedeem(Map deal) async {
    var urlForRedeem = Uri.parse(
        "https://petbottle-project-default-rtdb.firebaseio.com/managerdeals/manager.json");
    allDeals = allDeals.map((e) {
      if (e['dealName'] == deal['dealName']) {
        e['redeems'] += 1;
        return e;
      } else {
        return e;
      }
    }).toList();

    var resultForRedeem = await http.patch(urlForRedeem,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"deals": allDeals}));

    var body = json.decode(resultForRedeem.body);

    final SharedPreferences preference = await SharedPreferences.getInstance();
    var dataId = preference.getString('dataId');

    var url2 = Uri.parse(
        "https://petbottle-project-default-rtdb.firebaseio.com/usersdata/$dataId.json");

    var data = await http.get(url2);
    var decodedRedeem = json.decode(data.body);
    var redeem = [];
    if (decodedRedeem['previousRedeems'] != null) {
      redeem = decodedRedeem['previousRedeems'];
    }
    var currentPoints = decodedRedeem['points'];
    var requiredPoints = deal['requiredPoints'];
    var newPoints;
    if (currentPoints >= requiredPoints) {
      newPoints = decodedRedeem['points'] - deal['requiredPoints'];
      var result2 = await http.patch(url2,
          headers: {"Content-Type": "application/json"},
          body: json.encode({
            "previousRedeems": [...redeem, deal],
            "points": newPoints
          }));

      var body2 = await json.decode(result2.body);
      handleData();
    } else {
      print("Points not Enough!!");
      // Fluttertoast.showToast(
      //     msg: "Points not Enough!!",
      //     toastLength: Toast.LENGTH_SHORT,
      //     gravity: ToastGravity.CENTER,
      //     timeInSecForIosWeb: 1,
      //     backgroundColor: Colors.red,
      //     textColor: Colors.white,
      //     fontSize: 16.0);
    }
  }

  Future<void> _showMyDialog(String msg) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Change $msg'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                TextFormField(
                  decoration: InputDecoration(
                    labelText: msg,
                  ),
                  keyboardType: msg == "Mobile No."
                      ? TextInputType.number
                      : TextInputType.text,
                  maxLength: 50,
                  onChanged: (v) {
                    if (msg == "First Name") {
                      firstName = v;
                    } else if (msg == "Last Name") {
                      lastName = v;
                    } else if (msg == "Email Address") {
                      email = v;
                    } else if (msg == "Mobile No.") {
                      mobileNo = v;
                    }
                  },
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Change'),
              onPressed: () {
                setState(() {
                  if (msg == "First Name") {
                    userData['firstName'] = firstName;
                  } else if (msg == "Last Name") {
                    userData['lastName'] = lastName;
                  } else if (msg == "Email Address") {
                    changeEmail();

                    userData['email'] = email;
                  } else if (msg == "Mobile No.") {
                    userData['mobileNo'] = mobileNo;
                  }
                });
                Navigator.of(context).pop();
              },
            )
          ],
        );
      },
    );
  }

  void filterDeals() {
    print(location);
    var arr = allDeals.where((val) {
      print(val['address']);
      if (val['address'].toString().toLowerCase().contains(location) == true) {
        return true;
      }
      return false;
    }).toList();
    setState(() {
      filteredDeals = arr;
      filterStatus = true;
    });
    print(filteredDeals);
  }

  @override
  Widget build(BuildContext context) {
    print("All Deals: $allDeals");
    print("Previous Redeems: ${previousRedeems}");
// Try reading data from the counter key. If it doesn't exist, return 0.
    if (allDeals.length == 0) {
      getAllDeals().whenComplete(() => print("Deals Fetched!!!"));
    }

    if (previousRedeems.length == 0) {
      getPreviousRedeems()
          .whenComplete(() => print("Previous Redeems Fetched!!!"));
    }

    return Scaffold(
        body: DefaultTabController(
      length: 3,
      child: Scaffold(
          appBar: AppBar(
              backgroundColor: Color.fromRGBO(0, 200, 0, 1),
              bottom: TabBar(
                tabs: [
                  Tab(icon: Icon(Icons.home_filled)),
                  Tab(icon: Icon(Icons.book_outlined)),
                  Tab(icon: Icon(Icons.info_outline)),
                ],
              ),
              title: Text('Dashboard'),
              actions: <Widget>[
                Padding(
                    padding: EdgeInsets.only(right: 20.0, top: 18.0),
                    child: GestureDetector(
                      onTap: () {},
                      child: userData != null
                          ? Text(
                              userData['points'].toString() + " Points",
                              style: TextStyle(
                                  fontSize: 20.0, fontWeight: FontWeight.bold),
                            )
                          : Text(""),
                    ))
              ]),
          body: Container(
            margin:
                EdgeInsets.only(top: 15.0, left: 5.0, right: 5.0, bottom: 5.0),
            child: TabBarView(
              children: [
                Column(
                  children: [
                    TextField(
                      decoration: InputDecoration(
                        labelText: "Filter by Location",
                        prefixIcon: Icon(FlutterIcons.location_arrow_faw,
                            color: Color.fromRGBO(0, 200, 0, 1)),
                      ),
                      onChanged: (v) {
                        location = v;
                      },
                      maxLength: 30,
                    ),
                    Container(
                        margin: EdgeInsets.only(top: 30.0),
                        child: ElevatedButton(
                            child: Text("Search"),
                            onPressed: () => filterDeals(),
                            style: ButtonStyle(
                                backgroundColor:
                                    MaterialStateProperty.all<Color>(
                                        Colors.lightGreen.shade800),
                                fixedSize: MaterialStateProperty.all(
                                    Size.fromWidth(320))))),
                    filterStatus == true
                        ? Container(
                            child: ElevatedButton(
                                child: Text("Show all Deals"),
                                onPressed: () {
                                  setState(() {
                                    filterStatus = false;
                                  });
                                },
                                style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all<Color>(
                                            Colors.lightGreen.shade800),
                                    fixedSize: MaterialStateProperty.all(
                                        Size.fromWidth(320)))))
                        : Text(""),
                    allDeals.length == 0
                        ? Container(
                            margin: EdgeInsets.only(top: 30.0), child: Text(""))
                        : Expanded(
                            child: SizedBox(
                              height: 200.0,
                              child: new ListView.builder(
                                scrollDirection: Axis.vertical,
                                itemCount: filterStatus == false
                                    ? allDeals.length
                                    : filteredDeals.length,
                                itemBuilder: (BuildContext ctxt, int index) {
                                  return new Container(
                                      margin: EdgeInsets.only(top: 30.0),
                                      child: ListTile(
                                          title: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Stack(children: <Widget>[
                                                  new Image.memory(
                                                      base64.decode(
                                                          filterStatus == false
                                                              ? allDeals[index]
                                                                  ['image']
                                                              : filteredDeals[
                                                                      index]
                                                                  ['image']),
                                                      width: 340,
                                                      height: 180,
                                                      fit: BoxFit.fill),
                                                  Column(children: [
                                                    Container(
                                                        margin: EdgeInsets.only(
                                                            top: 20.0),
                                                        padding:
                                                            EdgeInsets.all(5.0),
                                                        width: 100,
                                                        // height: 20,
                                                        decoration: BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        10),
                                                            color:
                                                                Color.fromRGBO(
                                                                    255,
                                                                    40,
                                                                    77,
                                                                    1)),
                                                        child: Text(
                                                          filterStatus == false
                                                              ? "${allDeals[index]['percentDiscount']}% OFF"
                                                              : "${filteredDeals[index]['percentDiscount']}% OFF",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                              color: Color
                                                                  .fromRGBO(
                                                                      255,
                                                                      255,
                                                                      255,
                                                                      1)),
                                                        ))
                                                  ]),
                                                ]),
                                                Text(
                                                  filterStatus == false
                                                      ? allDeals[index]
                                                          ['dealName']
                                                      : filteredDeals[index]
                                                          ['dealName'],
                                                  style: TextStyle(
                                                      fontSize: 25.0,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                )
                                              ]),
                                          subtitle: Container(
                                              margin: EdgeInsets.only(
                                                  top: 10.0, bottom: 10.0),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(filterStatus == false
                                                      ? allDeals[index]
                                                          ['address']
                                                      : filteredDeals[index]
                                                          ['address']),
                                                  Text(
                                                      "Original Price: " +
                                                          (filterStatus == false
                                                                  ? allDeals[index]
                                                                          [
                                                                          'originalPrice']
                                                                      .toString()
                                                                  : filteredDeals[
                                                                          index]
                                                                      [
                                                                      'originalPrice'])
                                                              .toString() +
                                                          " Rs.",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      "Discounted Price: " +
                                                          (filterStatus == false
                                                              ? (allDeals[index][
                                                                          'originalPrice'] -
                                                                      (allDeals[index]['percentDiscount'] /
                                                                              100) *
                                                                          allDeals[index][
                                                                              'originalPrice'])
                                                                  .toString()
                                                              : (filteredDeals[index][
                                                                          'originalPrice'] -
                                                                      (filteredDeals[index]['percentDiscount'] /
                                                                              100) *
                                                                          filteredDeals[index][
                                                                              'originalPrice'])
                                                                  .toString()) +
                                                          " Rs.",
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Text(
                                                      "Required Points: " +
                                                          (filterStatus == false
                                                              ? allDeals[index][
                                                                      'requiredPoints']
                                                                  .toString()
                                                              : filteredDeals[
                                                                          index]
                                                                      [
                                                                      'requiredPoints']
                                                                  .toString()),
                                                      style: TextStyle(
                                                          fontWeight:
                                                              FontWeight.bold)),
                                                  Container(
                                                      child: ElevatedButton(
                                                          child: Text("Redeem"),
                                                          onPressed: () {
                                                            updateRedeem(
                                                                allDeals[
                                                                    index]);
                                                          },
                                                          style: ButtonStyle(
                                                              backgroundColor:
                                                                  MaterialStateProperty.all<
                                                                          Color>(
                                                                      Colors
                                                                          .lightGreen
                                                                          .shade800),
                                                              fixedSize: MaterialStateProperty
                                                                  .all(Size
                                                                      .fromWidth(
                                                                          120)))))
                                                ],
                                              ))));
                                },
                              ),
                            ),
                          ),
                  ],
                ),
                Column(
                  children: [
                    previousRedeems.length == 0
                        ? Container(
                            margin: EdgeInsets.only(top: 30.0), child: Text(""))
                        : Text("Previous Redeems",
                            style: TextStyle(
                                fontSize: 30.0, fontWeight: FontWeight.bold)),
                    Expanded(
                      child: SizedBox(
                        height: 200.0,
                        child: new ListView.builder(
                          scrollDirection: Axis.vertical,
                          itemCount: previousRedeems.length,
                          itemBuilder: (BuildContext ctxt, int index) {
                            return new Container(
                                margin: EdgeInsets.all(5.0),
                                decoration: BoxDecoration(
                                    border: Border.all(
                                  color: Colors.black,
                                  width: 1.0,
                                )),
                                child: ListTile(
                                  title: Text(
                                    previousRedeems[index]['dealName'],
                                    style: TextStyle(
                                        fontSize: 15.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(previousRedeems[index]
                                          ['requiredPoints']
                                      .toString()),
                                ));
                          },
                        ),
                      ),
                    ),
                  ],
                ),
                userData != null
                    ? Column(
                        children: [
                          Container(
                              padding: EdgeInsets.all(10.0),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                color: Colors.black,
                                width: 1.0,
                              )),
                              child: Column(
                                children: [
                                  TextButton(
                                    child: Text("Email Address",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    onPressed: () =>
                                        _showMyDialog('Email Address'),
                                  ),
                                  Text(userData['email']),
                                  TextButton(
                                      child: Text("First Name",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      onPressed: () =>
                                          _showMyDialog('First Name')),
                                  Text(userData['firstName']),
                                  TextButton(
                                      child: Text("Last Name",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      onPressed: () =>
                                          _showMyDialog('Last Name')),
                                  Text(userData['lastName']),
                                  TextButton(
                                      child: Text("Mobile No.",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      onPressed: () =>
                                          _showMyDialog('Mobile No.')),
                                  Text(userData['mobileNo']),
                                ],
                              )),
                          Container(
                              margin: EdgeInsets.only(top: 30.0),
                              child: ElevatedButton(
                                  child: Text("Save Data"),
                                  onPressed: () => updateData(),
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.lightGreen.shade800),
                                      fixedSize: MaterialStateProperty.all(
                                          Size.fromWidth(320))))),
                          Container(
                              margin: EdgeInsets.only(top: 30.0),
                              child: ElevatedButton(
                                  child: Text("Logout"),
                                  onPressed: () async {
                                    final SharedPreferences preference =
                                        await SharedPreferences.getInstance();
                                    await preference.remove('email');
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(builder: (_) {
                                      return (LoginWidget());
                                    }));
                                  },
                                  style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all<Color>(
                                              Colors.lightGreen.shade800),
                                      fixedSize: MaterialStateProperty.all(
                                          Size.fromWidth(320))))),
                        ],
                      )
                    : Text(""),
              ],
            ),
          )),
    ));
  }
}
