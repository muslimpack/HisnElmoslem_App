import 'package:hisnelmoslem/models/tally.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:flutter/material.dart';
import 'package:hisnelmoslem/shared/custom_inputs/number_field.dart';
import 'package:hisnelmoslem/shared/custom_inputs/text_field.dart';

class EditTallyDialog extends StatefulWidget {
  final DbTally dbTally;
  final Function(DbTally) onSubmit;

  const EditTallyDialog({
    Key? key,
    required this.dbTally,
    required this.onSubmit,
  }) : super(key: key);

  @override
  State<EditTallyDialog> createState() => _EditTallyDialogState();
}

class _EditTallyDialogState extends State<EditTallyDialog> {
  TextEditingController titleController = TextEditingController();

  TextEditingController resetCounterController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    titleController = TextEditingController(text: widget.dbTally.title);
    resetCounterController =
        TextEditingController(text: widget.dbTally.countReset.toString());
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: Card(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        margin: const EdgeInsets.all(0.0),
        color: Theme.of(context).scaffoldBackgroundColor,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "تعديل عداد حالي",
                style: TextStyle(
                  fontSize: 25,
                  color: mainColor,
                ),
              ),
            ),
            const Divider(),
            const Text(
              "أدخل اسم العداد مثال\nصل على محمد\nسبحان الله والحمد لله ولا إاله إلا الله والله أكبر",
              textAlign: TextAlign.center,
            ),
            UserTextField(
              controller: titleController,
              hintText: "أدخل اسم العداد",
            ),
            const Text(
              "عند الوصول إلى هذا الرقم يتم ضبط العداد ليعود إلى الصفر لتتكرر هذه الدورة باستمرار",
              textAlign: TextAlign.center,
            ),
            UserNumberField(
              controller: resetCounterController,
              hintText: "أدخل رقم لضبط العداد",
            ),
            const Divider(),
            Row(
              children: [
                Expanded(
                  child: ListTile(
                    title: const Text(
                      "تم",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 20, color: mainColor),
                    ),
                    onTap: () {
                      widget.dbTally.title = titleController.text;
                      widget.dbTally.countReset =
                          int.parse(resetCounterController.text);
                      widget.onSubmit(widget.dbTally);
                      Navigator.pop<bool>(context, true);
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
