import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:orderapp/model/model.dart';

class Controller extends ChangeNotifier {
  Future<RegistrationData?> postRegistration(String company_code) async {
    print("helooooo");
    try {
      Uri url = Uri.parse("http://trafiqerp.in/order/fj/get_registration.php");
      Map body = {
        'company_code': company_code,
      };
      http.Response response =
          await http.post(url, body: body, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      });
      print("body ${body}");

      var map = jsonDecode(response.body);
      print("map ${map}");

      print("response ${response}");
      RegistrationData regModel = RegistrationData.fromJson(map);
      // int uid=int.parse(map["UserId"].toString());
      // var result=await BarcodeScanlogDB.instance.insertRegistrationDetails(company_code, device_id, "free to scan",map["CompanyId"], map["CompanyName"], map["UserId"], map["ExpiryDate"]);
      return regModel;
    } catch (e) {
      print(e);
      return null;
    }
  }
}
