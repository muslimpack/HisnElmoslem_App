import 'package:flutter/material.dart';
// class AlarmCard extends StatefulWidget {
//   final List<DbAlarm> dbAlarmList;
//   final int index;
//
//   const AlarmCard({Key key, @required this.dbAlarmList, @required this.index})
//       : super(key: key);
//
//   @override
//   _AlarmCardState createState() => _AlarmCardState();
// }
//
// class _AlarmCardState extends State<AlarmCard> {
//   bool isActive = false;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.dbAlarmList[widget.index].isActive == 1) {
//       setState(() {
//         isActive = true;
//       });
//     } else {
//       isActive = false;
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return new Slidable(
//       actionPane: SlidableDrawerActionPane(),
//       actionExtentRatio: .2,
//       actions: [
//             RoundButton(
//               widget: Icon(Icons.delete),
//               color: Colors.red.shade300,
//               onTap: (){
//                 setState(() {
//                   showToast(msg:'${widget.index}' );
//                   alarmDatabaseHelper.deleteAlarm(
//                       dbAlarm: widget.dbAlarmList[widget.index]);
//                   widget.dbAlarmList.removeAt(widget.index);
//                 });
//                 setState(() {
//
//                 });
//               },
//             ),
//       ],
//       secondaryActions: [
//             RoundButton(
//               widget: Icon(Icons.edit),
//               color: Colors.green.shade300,
//               onTap: (){
//                 showToast(msg:'${widget.index}' );
//                 showFastEditAlarmDialog(context: context, dbAlarm: widget.dbAlarmList[widget.index]);
//               },
//
//             ),
//       ],
//       child: Column(
//         children: [
//           // Wrap(
//           //
//           //   children: [
//           //     RoundButton(
//           //       widget: Icon(Icons.edit),
//           //       color: Colors.green.shade300,
//           //       onTap: (){
//           //         showFastEditAlarmDialog(context: context, dbAlarm: widget.dbAlarmList[widget.index]);
//           //       },
//           //
//           //     ),
//           //     RoundButton(
//           //       widget: Icon(Icons.delete),
//           //       color: Colors.red.shade300,
//           //       onTap: (){
//           //         setState(() {
//           //           // showToast(msg: '${widget.index}');
//           //           widget.dbAlarmList.removeAt(widget.index);
//           //           alarmDatabaseHelper.deleteAlarm(
//           //               dbAlarm: widget.dbAlarmList[widget.index]);
//           //         });
//           //       },
//           //     ),
//           //   ],
//           // ),
//           SwitchListTile(
//             title: ListTile(
//               contentPadding: EdgeInsets.all(0),
//               // leading: Icon(Icons.bookmark_border),
//               leading: Icon(
//                 Icons.alarm,
//               ),
//               subtitle: Wrap(
//                 children: [
//                   RoundTagCard(
//                     name: widget.dbAlarmList[widget.index].body ?? "",
//                     color: Colors.green.shade300,
//                   ),
//                   RoundTagCard(
//                     name:
//                         '⌚ ${widget.dbAlarmList[widget.index].hour} : ${widget.dbAlarmList[widget.index].minute}',
//                     color: Colors.blue.shade300,
//                   ),
//                   RoundTagCard(
//                     name: "Weekly",
//                     color: Colors.orange.shade300,
//                   ),
//                 ],
//               ),
//               isThreeLine: true,
//               title: Text(widget.dbAlarmList[widget.index].title),
//             ),
//             activeColor: MAINCOLOR,
//             value: isActive,
//             onChanged: (value) {
//               setState(() {
//                 //Update database
//                 DbAlarm updateAlarm = widget.dbAlarmList[widget.index];
//                 value ? updateAlarm.isActive = 1 : updateAlarm.isActive = 0;
//                 alarmDatabaseHelper.updateAlarmInfo(dbAlarm: updateAlarm);
//                 // update view
//                 isActive = value;
//                 //
//                 alarmManager.alarmState(dbAlarm: updateAlarm);
//               });
//             },
//           ),
//           // Divider(),
//         ],
//       ),
//     );
//   }
// }

class RoundButton extends StatelessWidget {
  final Widget widget;
  final Color color;
  final Function onTap;

  const RoundButton({Key? key,required this.widget,required this.color, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap:() =>  onTap(),
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5.0),
        ),
        color: color,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: widget,
        ),
      ),
    );
  }
}

class RoundTagCard extends StatelessWidget {
  final String name;
  final Color color;

  const RoundTagCard({Key? key, required this.name, required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(5.0),
        child: Text(name,
            style: TextStyle(fontSize: 12), textDirection: TextDirection.ltr),
      ),
    );
  }
}
