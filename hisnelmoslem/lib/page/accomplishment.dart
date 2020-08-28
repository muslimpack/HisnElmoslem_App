/*import 'package:flutter/material.dart';
import 'package:flutter_sparkline/flutter_sparkline.dart';

class Accomplishment extends StatefulWidget {
  Accomplishment({Key key}) : super(key: key);

  @override
  _AccomplishmentState createState() => _AccomplishmentState();
}

class _AccomplishmentState extends State<Accomplishment> {
  var data = [0.0, 1.0, 1.5, 2.0, 0.0, 0.0, -0.5, -1.0, -0.5, 0.0, 0.0];
  var data1 = [0.0, -2.0];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            centerTitle: true,
            title: Text(
              "الإنجازات",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 25),
            ),
            pinned: true,
            expandedHeight: 210,
            flexibleSpace: FlexibleSpaceBar(
              background: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(top: 70),
                      child: Text(
                        'وَفِي ذَٰلِكَ فَلْيَتَنَافَسِ الْمُتَنَافِسُونَ',
                        style: TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Container(
                      child: Text(
                        '[سورة المطففين 26]',
                        textAlign: TextAlign.end,
                        style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate(
              <Widget>[
                //

                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    textDirection: TextDirection.rtl,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      //
                      Card(
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0)),
                          child: Column(
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.only(top: 10, bottom: 10),
                                  child: Text(
                                    "الصلاة على النبي",
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.blue),
                                    textAlign: TextAlign.center,
                                  )),
                              BuildDiv(),
                              SizedBox(height: 20),
                              Container(
                                child: new Sparkline(
                                  data: data1,
                                  pointsMode: PointsMode.all,
                                  fillMode: FillMode.below,
                                  fillGradient: new LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.amber[800],
                                      Colors.amber[200]
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.amber[200],
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(40),
                                      bottomRight: Radius.circular(40)),
                                ),
                                height: 40,
                              )
                            ],
                          )),
                      //
                      Card(
                          margin: EdgeInsets.only(top: 10),
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0)),
                          child: Column(
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.only(top: 10, bottom: 10),
                                  child: Text(
                                    "سبحان الله وبحمده \n سبحان الله العظيم",
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.blue),
                                    textAlign: TextAlign.center,
                                  )),
                              BuildDiv(),
                              SizedBox(height: 20),
                              Container(
                                child: new Sparkline(
                                  data: data,
                                  pointsMode: PointsMode.all,
                                  fillMode: FillMode.below,
                                  fillGradient: new LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.amber[800],
                                      Colors.amber[200]
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.amber[200],
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(40),
                                      bottomRight: Radius.circular(40)),
                                ),
                                height: 40,
                              )
                            ],
                          )),
                      //
                      Card(
                          margin: EdgeInsets.only(top: 10),
                          elevation: 20,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(40.0)),
                          child: Column(
                            children: <Widget>[
                              Container(
                                  margin: EdgeInsets.only(top: 10, bottom: 10),
                                  child: Text(
                                    "سبحان الله وبحمده \n سبحان الله العظيم",
                                    style: TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.blue),
                                    textAlign: TextAlign.center,
                                  )),
                              BuildDiv(),
                              SizedBox(height: 20),
                              Container(
                                child: new Sparkline(
                                  data: data,
                                  pointsMode: PointsMode.all,
                                  fillMode: FillMode.below,
                                  fillGradient: new LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.amber[800],
                                      Colors.amber[200]
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                decoration: BoxDecoration(
                                  color: Colors.amber[200],
                                  borderRadius: BorderRadius.only(
                                      bottomLeft: Radius.circular(40),
                                      bottomRight: Radius.circular(40)),
                                ),
                                height: 40,
                              )
                            ],
                          )),
                      //
                    ],
                  ),
                ),

                //
              ],
            ),
          )
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
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      width: double.infinity,
      height: 1.0,
      color: Theme.of(context).backgroundColor,
    );
  }
}*/
