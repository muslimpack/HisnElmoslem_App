import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hisnelmoslem/page/dashboard.dart';

//* هذا الكود تم تعديله
//* المصدر
//* https://github.com/MarcusNg/flutter_onboarding_ui/blob/master/lib/utilities/styles.dart

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final int _numPages = 6;
  final PageController _pageController = PageController(initialPage: 0);
  int _currentPage = 0;

  List<Widget> _buildPageIndicator() {
    List<Widget> list = [];
    for (int i = _numPages; i != 0; i--) {
      list.add(i == _currentPage + 1 ? _indicator(true) : _indicator(false));
    }
    return list;
  }

  Widget _indicator(bool isActive) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 150),
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      height: 8.0,
      width: isActive ? 24.0 : 16.0,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Color(0xFF7B51D3),
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.light,
        child: Container(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Container(
                  alignment: Alignment.centerLeft,
                  child: FlatButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(MaterialPageRoute(
                          builder: (BuildContext context) => Dashboard()));
                    },
                    child: Text(
                      'تخط',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20.0,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 600.0,
                  child: PageView(
                    reverse: true,
                    physics: ClampingScrollPhysics(),
                    controller: _pageController,
                    onPageChanged: (int page) {
                      setState(() {
                        _currentPage = page;
                      });
                    },
                    children: <Widget>[
                      onboardingPages(
                          'assets/hisn.png',
                          'تطبيق حصن المسلم\n من أذكار الكتاب والسنة',
                          'تم الإعتماد على نسخة مكتوبة من كتاب حصن المسلم\n للدكتور سعيد بن علي بن وهف القحطاني \n بواسطة شبكة الألوكة'),
                      onboardingPages(
                          'assets/rosary.png',
                          'لا تنس نصيبك من التسبيح على أناملك',
                          'قالَ لنا رسولُ اللَّهِ صلَّى اللَّهُ عليهِ وسلَّمَ \n عليكنَّ بالتَّسبيحِ والتَّهليلِ والتَّقديسِ واعقِدنَ بالأناملِ فإنَّهنَّ مسؤولاتٌ مستنطقاتٌ ولا تغفلنَ فتنسينَ الرَّحمةَ \n الراوي : يسيرة بنت ياسر | المحدث : ابن حجر العسقلاني'),
                      onboardingPages(
                          'assets/rosary.png',
                          'لا تتباه على خلق الله بفضل الله عليك',
                          'لا تجعل السبحة التي بداخل التطبيق وعدها مدعاة للعجب إلا أن يكون تنافسا في الخير بين صحبك ففي ذلك فليتنافس المتنافسون '),
                      onboardingPages('assets/bookmark.png', 'المفضلة',
                          'تجد بها الأذكار التي تدوام عليها باستمرار في الغالب كأذكار الصباح و المساء و النوم ....'),
                      onboardingPages('assets/recommend.png', 'نوصي بها',
                          'هذا البرنامج الذي بين يديك صمم ليكون مجاني وخال من الإعلانات ومفتوح المصدر في هذه القائمة تجد تطبيقات نافعة إن شاء الله و خالية من الإعلانات'),
                      onboardingPages(
                          'assets/recommend.png',
                          'في حالة وجود خطأ',
                          'إما في الأذكار : فيمكنك الضغط على الأيقونة على شكل علامة التعجب و ستقوم بإرسالها على البريد الإلكتروني \n\n وإما في التطبيق بشكل عام: فمن خلال الإعدادات قم بإرسال تقييم للتطبيق'),
                    ],
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _buildPageIndicator(),
                ),
                _currentPage + 1 != _numPages
                    ? Expanded(
                        child: Align(
                          alignment: FractionalOffset.bottomRight,
                          child: FlatButton(
                            onPressed: () {
                              _pageController.nextPage(
                                duration: Duration(milliseconds: 500),
                                curve: Curves.ease,
                              );
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: <Widget>[
                                Icon(
                                  Icons.arrow_back,
                                  color: Colors.white,
                                  size: 30.0,
                                ),
                                SizedBox(width: 10.0),
                                Text(
                                  'التالي',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 22.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      )
                    : Text(''),
              ],
            ),
          ),
        ),
      ),
      bottomSheet: _currentPage + 1 == _numPages
          ? Container(
              height: 70.0,
              width: double.infinity,
              color: Colors.white,
              child: GestureDetector(
                onTap: () {
                  Navigator.of(context).pushReplacement(MaterialPageRoute(
                      builder: (BuildContext context) => Dashboard()));
                },
                child: Center(
                  child: Padding(
                    padding: EdgeInsets.only(bottom: 30.0),
                    child: Text(
                      'البدء',
                      style: TextStyle(
                        color: Color(0xFF5B16D0),
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            )
          : Text(''),
    );
  }

  onboardingPages(String imageAssets, String title, String subtitle) {
    return new Directionality(
        textDirection: TextDirection.rtl,
        child: Padding(
          padding: EdgeInsets.all(30.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Image(
                  image: AssetImage(
                    imageAssets,
                  ),
                  height: 250,
                  width: 250,
                ),
              ),
              SizedBox(height: 30.0),
              Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 26.0,
                  fontWeight: FontWeight.bold,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 15.0),
              Text(subtitle,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18.0,
                    height: 1.2,
                  )),
            ],
          ),
        ));
  }
}
