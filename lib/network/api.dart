import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class CallApi {

  // Header Content
  _setHeader() => {
        'Content-type': 'application/json',
        'Accept': 'application/json',
      };


  //Get Request
  getData(apiUrl) async {
    return await http.get(Uri.parse(apiUrl), headers: _setHeader());
  }

}