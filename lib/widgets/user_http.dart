import "package:http/http.dart" as http;
import "dart:convert";
import "dart:math";

class UserHTTP {
  static loginUser(String emailAddress, String password) async {
    final url = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=AIzaSyDpgSXCIPigSzmvciQnauTbvLfQVOjrH94");
    var result = await http.post(url,
        body: json.encode({
          "email": emailAddress,
          "password": password,
          "returnSecureToken": true
        }));

    return json.decode(result.body);
  }

  static sendOtp(mobileNo, firstName, lastName) async {
    Random random = new Random();
    String randomNumber = (random.nextInt(9000) + 1000).toString();
    var otpURI = Uri.parse(
        "https://sendpk.com/api/sms.php?username=923322201477&password=Imoperation021&sender=NCAI%20&mobile=92${int.parse(mobileNo)}&message=your code is $randomNumber");

    var otp = await http.get(otpURI);
    // var data = await json.decode(otp.body);
    print(otp.body);
    return randomNumber;
  }

  static getAllDeals() async {
    var dealUrl = Uri.parse(
        "https://petbottle-project-ae85a-default-rtdb.firebaseio.com/managerdeals.json");

    var allEmailsResult = await http.get(dealUrl);
    Map body = json.decode(allEmailsResult.body);
    if (body.runtimeType != Null) {
      // print("All Deals: " + body.toString());
      var arr = [];
      body.forEach((key, value) {
        if (value['deals'] != null) {
          List val = value['deals'];
          arr.addAll(val);
        }
      });
      return arr;
    }
  }

  static updatePassword(String idToken, String newPassword) async {
    var changePasswordURI = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:update?key=AIzaSyDpgSXCIPigSzmvciQnauTbvLfQVOjrH94");

    var result = await http.post(changePasswordURI,
        body: json.encode({
          "idToken": idToken,
          "password": newPassword,
          "returnSecureToken": false
        }));

    print(json.decode(result.body));
  }

  static updateEmail(String idToken, String email) async {
    var changeEmailURI = Uri.parse(
        "https://identitytoolkit.googleapis.com/v1/accounts:update?key=AIzaSyDpgSXCIPigSzmvciQnauTbvLfQVOjrH94");

    var result = await http.post(changeEmailURI,
        body: json.encode(
            {"idToken": idToken, "email": email, "returnSecureToken": false}));

    print(json.decode(result.body));
  }

  static handleData(dataId) async {
    var url2 = Uri.parse(
        "https://petbottle-project-ae85a-default-rtdb.firebaseio.com/usersdata/$dataId.json");

    var result2 = await http.get(url2);

    var body = await json.decode(result2.body);
    return body;
  }

  static updateData(userData, dataId) async {
    var url3 = Uri.parse(
        "https://petbottle-project-ae85a-default-rtdb.firebaseio.com/usersdata/$dataId.json");

    var result3 = await http.patch(url3,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          'email': userData['email'],
          'firstName': userData['firstName'],
          'lastName': userData['lastName'],
        }));
    print(json.decode(result3.body));
  }

  // static getUserData(dataId) async {
  //   var url2 = Uri.parse(
  //       "https://petbottle-project-ae85a-default-rtdb.firebaseio.com/usersdata/$dataId.json");

  //   var data = await http.get(url2);
  //   return json.decode(data.body);
  // }

  static patchData(dataId, currentRedeems, newPoints, mobileNo) async {
    var url2 = Uri.parse(
        "https://petbottle-project-ae85a-default-rtdb.firebaseio.com/usersdata/$dataId.json");

    var result2 = await http.patch(url2,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "previousRedeems": currentRedeems,
        }));

    var url3 = Uri.parse(
        "https://petbottle-project-ae85a-default-rtdb.firebaseio.com/newuserdata/$mobileNo.json");

    await http.patch(url3,
        headers: {"Content-Type": "application/json"},
        body: json.encode({
          "points": newPoints,
        }));
    return await json.decode(result2.body);
  }

  static updateManagerDeals(allDeals) async {
    var urlForRedeem = Uri.parse(
        "https://petbottle-project-ae85a-default-rtdb.firebaseio.com/managerdeals/manager.json");
    var resultForRedeem = await http.patch(urlForRedeem,
        headers: {"Content-Type": "application/json"},
        body: json.encode({"deals": allDeals}));

    return json.decode(resultForRedeem.body);
  }

  static fetchUserPoints(mobileNo) async {
    var url = Uri.parse(
        "https://petbottle-project-ae85a-default-rtdb.firebaseio.com/newuserdata/$mobileNo.json");

    var result = await http.get(url);

    var data = json.decode(result.body);

    return data;
  }
}
