import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class RearrangeDashboardPageController extends GetxController {
  /* *************** Variables *************** */
  final box = GetStorage();

  List<int> list = <int>[].obs;

  late final ColorScheme colorScheme = Theme.of(Get.context!).colorScheme;
  late final Color oddItemColor = colorScheme.primary.withOpacity(0.05);
  late final Color evenItemColor = colorScheme.primary.withOpacity(0.15);

  bool isLoading = true;

  /* *************** Controller life cycle *************** */
  @override
  void onInit() {
    super.onInit();
    buildListFromString();

    isLoading = false;
    update();
  }

  /* *************** Functions *************** */

  /// get Tally Transition Vibrate mode
  String get listArrangeString => box.read('list_arrange') ?? "";

  /// set Tally  Transition Vibrate mode
  void changeListArrange(String val) {
    box.write('list_arrange', val);
    update();
  }

  List<int> buildListFromString() {
    if (listArrangeString == "") {
      list = [0, 1, 2];
    } else {
      String _list = listArrangeString.replaceAll('[', '').replaceAll(']', '');
      list.clear();
      list.addAll(_list.split(",").map<int>((e) => int.parse(e)).toList());
    }

    return list;
  }

  void onReorder(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final int item = list.removeAt(oldIndex);
    list.insert(newIndex, item);
    changeListArrange(list.toString());
    buildListFromString();
    debugPrint(list.toString());
    update();
  }
}
