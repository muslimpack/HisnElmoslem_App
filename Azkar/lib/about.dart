import 'package:flutter/material.dart';

class About extends StatefulWidget {
  About({Key key}) : super(key: key);

  @override
  _AboutState createState() => _AboutState();
}

class _AboutState extends State<About> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 10,
        centerTitle: true,
        title: new Text(
          "عن التطبيق",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
        ),
      ),
      body: ListView(
        children: <Widget>[
          const SizedBox(height: 10),

          //المراجع
          Card(
            elevation: 5,
            margin: EdgeInsets.fromLTRB(10, 15, 10, 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: <Widget>[
                new ListTile(
                  title: Text(
                    "المراجع",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                BuildDiv(),
                new Directionality(
                    textDirection: TextDirection.rtl,
                    child: new ListTile(
                      title: Text(
                        "حصن المسلم \n من أذكار الكتاب و السنة  ",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )),
                BuildDiv(),
                new Directionality(
                    textDirection: TextDirection.rtl,
                    child: new ListTile(
                      title: Text(
                        "للفقير إلى الله تعالى \n د. سعيد بن علي بن وهف القحطاني ",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )),
                BuildDiv(),
                new Directionality(
                    textDirection: TextDirection.rtl,
                    child: new ListTile(
                      title: Text(
                        "تم الإعتماد على نسخة مكتوبة من الكتيب \n بواسطة شبكة الألوكة",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )),
              ],
            ),
          ),

          //التطبيق
          Card(
            elevation: 5,
            margin: EdgeInsets.fromLTRB(10, 15, 10, 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: <Widget>[
                new ListTile(
                  title: Text(
                    "التطبيق",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                BuildDiv(),
                new Directionality(
                    textDirection: TextDirection.rtl,
                    child: new ListTile(
                      title: Text(
                        "هذا التطبيق صدقة جارية لوالدي أطال الله بالخير أعمارهم",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )),
              ],
            ),
          ),

          //المطور
          Card(
            elevation: 5,
            margin: EdgeInsets.fromLTRB(10, 15, 10, 15),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            child: Column(
              children: <Widget>[
                new ListTile(
                  title: Text(
                    "مطور التطبيق",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                ),
                BuildDiv(),
                new Directionality(
                    textDirection: TextDirection.rtl,
                    child: new ListTile(
                      title: Text(
                        "حسن الطنطاوي",
                        style: TextStyle(
                          fontSize: 20,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    )),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class BuildDiv extends StatelessWidget {
  const BuildDiv({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8.0),
      width: double.infinity,
      height: 1.0,
      color: Theme.of(context).backgroundColor,
    );
  }
}
