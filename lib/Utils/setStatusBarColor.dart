import 'package:flutter/services.dart';
import 'package:hoochat_web/Configs/app_constants.dart';

setStatusBarColor() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: fiberchatPRIMARYcolor,
      statusBarIconBrightness: Brightness.light));
}
