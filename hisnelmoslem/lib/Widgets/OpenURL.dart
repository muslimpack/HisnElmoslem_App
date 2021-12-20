import 'package:flutter/cupertino.dart';
import 'package:url_launcher/url_launcher.dart';

sendEmail({@required String toMailId,@required String subject,@required String body}) async {
  var url = 'mailto:$toMailId?subject=$subject&body=$body';
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}

openURL(String url) async {
  if (await canLaunch(url)) {
    await launch(url);
  } else {
    throw 'Could not launch $url';
  }
}