import 'package:flutter/material.dart';
import 'package:hisnelmoslem/Shared/Widgets/Loading.dart';
import 'package:hisnelmoslem/Utils/azkar_database_helper.dart';
import 'package:hisnelmoslem/models/zikr_title.dart';
import 'package:hisnelmoslem/shared/cards/zikr_card.dart';

class AzkarFehrs extends StatefulWidget {
  final bool isSearching;
  final String searchTxt;

  const AzkarFehrs(
      {Key? key, required this.isSearching, required this.searchTxt})
      : super(key: key);

  @override
  _AzkarFehrsState createState() => _AzkarFehrsState();
}

class _AzkarFehrsState extends State<AzkarFehrs> {
  final ScrollController _controllerOne = ScrollController();

  List<DbTitle> zikr = <DbTitle>[];
  List<DbTitle> _zikrForDisplay = <DbTitle>[];
  bool isLoading = false;

  @override
  void dispose() {
    _controllerOne.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    setState(() {
      isLoading = true;
    });
    getAllListsReady();

    _zikrForDisplay = zikr;
    setState(() {
      isLoading = false;
    });
  }

  getAllListsReady() async {
    //AzkarPageList

    await azkarDatabaseHelper.getAllTitles().then((value) {
      setState(() {
        zikr = value;
      });
    });

    //QuranPageLists

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isSearching) {
      if (widget.searchTxt.isEmpty || widget.searchTxt == "") {
        _zikrForDisplay = zikr.where((zikr) {
          var zikrTitle = zikr.name;
          return zikrTitle.contains("");
        }).toList();
      } else {
        setState(() {
          _zikrForDisplay = zikr.where((zikr) {
            var zikrTitle = zikr.name.replaceAll(
                new RegExp(String.fromCharCodes([
                  1617,
                  124,
                  1614,
                  124,
                  1611,
                  124,
                  1615,
                  124,
                  1612,
                  124,
                  1616,
                  124,
                  1613,
                  124,
                  1618
                ])),
                "");
            return zikrTitle.contains(widget.searchTxt);
          }).toList();
        });
      }
    } else {
      _zikrForDisplay = zikr.where((zikr) {
        var zikrTitle = zikr.name;
        return zikrTitle.contains("");
      }).toList();
    }
    return isLoading
        ? Loading()
        : Scaffold(
            body: Scrollbar(
              controller: _controllerOne,
              isAlwaysShown: false,
              child: new ListView.builder(
                padding: EdgeInsets.only(top: 10),
                itemBuilder: (context, index) {
                  return ZikrCard(index: index, fehrsTitle: _zikrForDisplay);
                },
                itemCount: _zikrForDisplay.length,
              ),
            ),
          );
  }
}
