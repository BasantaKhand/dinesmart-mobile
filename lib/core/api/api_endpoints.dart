import 'dart:io';

import 'package:flutter/foundation.dart';

class ApiEndpoints {
  ApiEndpoints._();

  // Base URL - change this for production
  // static const String baseUrl = 'http://10.0.2.2:3000/api/v1';
  //static const String baseUrl = 'http://localhost:3000/api/v1';
  // For Android Emulator use: 'http://10.0.2.2:3000/api/v1'
  // For iOS Simulator use: 'http://localhost:5000/api/v1'
  // For Physical Device use your computer's IP: 'http://192.168.x.x:5000/api/v1'

  //Base url for development phase...to run multiple devices at a time...
  static String get baseUrl {
    //if run in web or simulator
    if (kIsWeb || Platform.isIOS) {
      return 'http://localhost:3000/api/v1';
    }else if(Platform.isAndroid){    // if run in emulator       
      return 'http://10.0.2.2:3000/api/v1'; 
    }else{ //pc id address if run in physical device
      return 'http://192.168.1.10:3000/api/v1';
    }
  }



  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);



  // ============ User Endpoints ============
  static const String users = '/users';
  static const String userLogin = '/users/login';
  static String userById(String id) => '/users/$id';
  static String userPhoto(String id) => '/users/$id/photo';

}
