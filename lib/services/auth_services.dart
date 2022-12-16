import 'dart:convert';
import 'dart:io';

import 'package:app_diario/services/webclient.dart';
import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';



class AuthService {
  //TODO: Modularizar o endpoint
  String url = WebClient.url;
  http.Client client = WebClient().client;


  Future<bool> login({required String email, required String password}) async {
    http.Response response = await client.post(Uri.parse('${url}login'),
        body: {'email': email, 'password': password});
    if (response.statusCode != 200) {
      String content = json.decode(response.body);
      switch (content) {
        case "Cannot find user":
          throw UserNotFindException();
      }
      throw HttpException(response.body);
    }
    saveUserInfos(response.body);
    return true;
  }

  Future<bool> register(
      {required String email, required String password}) async {
    http.Response response = await client.post(Uri.parse('${url}register'),
        body: {'email': email, 'password': password});
    if (response.statusCode != 201) {

      throw HttpException(response.body);
    }
    saveUserInfos(response.body);
    return true;
  }

  saveUserInfos(String body) async {
    Map<String, dynamic> map = json.decode(body);

    String token = map["accesToken"];
    String email = map["user"]["email"];
    int id = map["user"]["id"];

    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("accesToken", token);
    prefs.setString("email", email);
    prefs.setInt("id", id);


  }
}

class UserNotFindException implements Exception {}