import 'package:flutter/material.dart';

class About extends StatefulWidget {
  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("عن التطبيق"),
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
      ),
      body: ListView(
        children: [
          Image.asset('assets/images/app_icon.png'),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 5),
            child: Text(
              "حصن المسلم \n تطبيق مجاني خالي من الإعلانات ومفتوح المصدر \n\n تم الاستعانة بنسخة ديجتال من كتاب حصن المسلم \n للفقير إلى الله تعالى \n الدكتور سعيد بن علي بن وهف القحطاني \n من موقع الألوكة \n\n صفحات القرآن الموجودة داخل التطبيق تم تضمينها من تطبيق \n قرأن أندرويد",
              textAlign: TextAlign.center,
              softWrap: true,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                  fontSize: 15,
                  // fontSize: 20,
                  fontWeight: FontWeight.w700),
            ),
          ),

        ],
      ),
    );
  }
}
