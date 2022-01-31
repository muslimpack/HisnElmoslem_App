// import 'package:flutter/material.dart';
// import 'package:hisnelmoslem/models/zikr_content.dart';
// import 'package:hisnelmoslem/models/zikr_title.dart';
// import 'package:hisnelmoslem/utils/azkar_database_helper.dart';
// import 'package:hisnelmoslem/views/pages/bookmarks.dart';

// class FavouriteZikr extends StatefulWidget {
//   final List<DbContent> zikrContent;
//   const FavouriteZikr({Key? key, required this.zikrContent}) : super(key: key);

//   @override
//   _FavouriteZikrState createState() => _FavouriteZikrState();
// }

// class _FavouriteZikrState extends State<FavouriteZikr> {
//   @override
//   Widget build(BuildContext context) {
//     return ListView.builder(
//       itemCount: widget.zikrContent.length,
//       itemBuilder: (BuildContext context, int index) {
//         DbTitle? dbTitle;
//         azkarDatabaseHelper
//             .getTitleByIndex(index: widget.zikrContent[index].id)
//             .then((value) {
//           dbTitle = value;
//         });
//         return Card(
//           child: Padding(
//             padding: const EdgeInsets.symmetric(vertical: 10),
//             child: Column(
//               children: [
//                 Card(child: Text(dbTitle!.name ?? "")),
//                 Card(child: Text(widget.zikrContent[index].toString())),
//                 Card(child: Text(widget.zikrContent[index].toString())),
//               ],
//             ),
//           ),
//         );
//       },
//     );
//   }
// }
