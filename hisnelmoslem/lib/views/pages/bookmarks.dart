import 'package:flutter/material.dart';
import 'package:hisnelmoslem/Shared/Widgets/Loading.dart';
import 'package:hisnelmoslem/Shared/constant.dart';
import 'package:hisnelmoslem/Utils/azkar_database_helper.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:hisnelmoslem/shared/cards/zikr_card.dart';

class AzkarBookmarks extends StatefulWidget {
  @override
  _AzkarBookmarksState createState() => _AzkarBookmarksState();
}

class _AzkarBookmarksState extends State<AzkarBookmarks> {
  final ScrollController _controllerOne = ScrollController();
  List<DbTitle> favouriteAzkar = <DbTitle>[];

  bool isLoading = false;

  fetchAzkar() async {
    favouriteAzkar = <DbTitle>[];
    setState(() {
      isLoading = true;
    });
    //
    await azkarDatabaseHelper.getAllTitles().then((value) {
      setState(() {
        value.forEach((element) {
          if (element.favourite == 1) {
            favouriteAzkar.add(element);
          } else {
            favouriteAzkar.remove(element);
            debugPrint(" favouriteAzkar.remove(element);");
          }
        });
      });
    });
    //
    setState(() {
      isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    fetchAzkar();
  }

  @override
  void dispose() {
    _controllerOne.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Loading()
        : Scaffold(
            body: RefreshIndicator(
              color: MAINCOLOR,
              onRefresh: () async {
                fetchAzkar();
              },
              child: Scrollbar(
                controller: _controllerOne,
                isAlwaysShown: false,
                child: new ListView.builder(
                  padding: EdgeInsets.only(top: 10),
                  itemBuilder: (context, index) {
                    return ZikrCard(index: index, fehrsTitle: favouriteAzkar);
                  },
                  itemCount: favouriteAzkar.length,
                ),
              ),
            ),
          );
  }
}
