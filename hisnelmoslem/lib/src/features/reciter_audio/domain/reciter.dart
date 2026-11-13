import 'package:equatable/equatable.dart';

/// A reciter whose recordings are offered by the reference site.
class Reciter extends Equatable {
  /// Stable key used in `contents.audio_urls` and in folder names.
  final String slug;
  final String nameAr;
  final String nameEn;

  /// True for the reciter of the recordings bundled with the app.
  final bool isBundled;

  const Reciter({
    required this.slug,
    required this.nameAr,
    required this.nameEn,
    this.isBundled = false,
  });

  @override
  List<Object?> get props => [slug, nameAr, nameEn, isBundled];

  static const Reciter hamadAlduraihem = Reciter(
    slug: 'hamad_alduraihem',
    nameAr: 'حمد الدريهم',
    nameEn: 'Hamad Al-Duraihem',
    isBundled: true,
  );
  static const Reciter sulaimanAlshuwaihi = Reciter(
    slug: 'sulaiman_alshuwaihi',
    nameAr: 'سليمان الشويهي',
    nameEn: 'Sulaiman Al-Shuwaihi',
  );
  static const Reciter rashidAlhulaibah = Reciter(
    slug: 'rashid_alhulaibah',
    nameAr: 'راشد الحليبة',
    nameEn: 'Rashid Al-Hulaibah',
  );

  static const List<Reciter> all = [hamadAlduraihem, sulaimanAlshuwaihi, rashidAlhulaibah];

  static const Reciter defaultReciter = hamadAlduraihem;

  /// The reciter with [slug], or null.
  static Reciter? bySlug(String? slug) {
    for (final r in all) {
      if (r.slug == slug) return r;
    }
    return null;
  }
}
