import 'dart:async';
import 'package:flutter/services.dart';


class MsalLoginFlutter {

static const MethodChannel _channel = const MethodChannel('msal_login');
String _kAuthority; 
List<String> _kScopes;

MsalLoginFlutter();

MsalLoginFlutter.getInformation(String kAuthority, List<String> kScopes){
  _kAuthority = kAuthority;
  _kScopes = kScopes;
}

 static Future<MsalLoginFlutter> init({String kAuthority, List<String> kScopes}) async {
   var res = MsalLoginFlutter.getInformation(kAuthority, kScopes);
  return  await res._initialize();  
  }

   Future _initialize() async {
    var res = <String, dynamic>{'kAuthority': _kAuthority};
    //if authority has been set, add it aswell
    if (_kScopes != null)
      res["kScopes"] = _kScopes;

    try {
      await _channel.invokeMethod('initialize', res);
    } on PlatformException catch (e) {
      throw e;
    }
  }

   /// Acquire a token, with no user interaction
  Future<String> acquireToken() async {
    //call platform
    try {
      return await _channel.invokeMethod('getToken');
    } on PlatformException catch (e) {
      throw e;
    }
  }

   Future logout() async {
    try {
      await _channel.invokeMethod('logout', <String, dynamic>{});
    } on PlatformException catch (e) {
      throw e;
    }
  }

}