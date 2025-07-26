
import 'package:get_storage/get_storage.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/search_for.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/search_type.dart';

class SearchRepo {
  final GetStorage box;

  SearchRepo(this.box);

  /// Search Type
  static const String searchTypeKey = "searchType";
  SearchType get searchType {
    final data = box.read(searchTypeKey) as String?;
    if (data == null) return SearchType.typical;
    return SearchType.fromString(data);
  }

  Future setSearchType(SearchType searchType) {
    return box.write(searchTypeKey, searchType.name);
  }

  /// Search for
  static const String searchForKey = "searchFor";
  SearchFor get searchFor {
    final data = box.read(searchForKey) as String?;
    if (data == null) return SearchFor.title;
    return SearchFor.fromString(data);
  }

  Future setSearchFor(SearchFor searchFor) {
    return box.write(searchForKey, searchFor.name);
  }
}
