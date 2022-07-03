import 'package:flutter/material.dart';
import 'package:hisnelmoslem/models/tally.dart';
import 'package:hisnelmoslem/shared/constants/constant.dart';
import 'package:hisnelmoslem/shared/custom_inputs/number_field.dart';
import 'package:hisnelmoslem/shared/custom_inputs/text_field.dart';
import 'package:hisnelmoslem/shared/dialogs/dialog_maker.dart';

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
    return DialogMaker(
      height: 400,
      header: Text(
        "تعديل عداد حالي",
        style: TextStyle(
          fontSize: 25,
          color: mainColor,
        ),
      ),
      content: [
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
      ],
      footer: ListTile(
        title: Text(
          "تم",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, color: mainColor),
        ),
        onTap: () {
          widget.dbTally.title = titleController.text;
          widget.dbTally.countReset = int.parse(resetCounterController.text);
          widget.onSubmit(widget.dbTally);
          Navigator.pop<bool>(context, true);
        },
      ),
    );
  }
}
