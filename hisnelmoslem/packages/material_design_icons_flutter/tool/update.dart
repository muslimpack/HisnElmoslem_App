import 'dart:io';
import 'dart:async';

const mdiRepo =
    'https://raw.githubusercontent.com/Templarian/MaterialDesign-Webfont';
const fontFile = '$mdiRepo/master/fonts/materialdesignicons-webfont.ttf';
const icons = '$mdiRepo/master/scss/_variables.scss';

const reversedKeywords = ['null', 'switch', 'sync', 'factory'];

Future download(String link, String name) {
  return (new HttpClient()
      .getUrl(Uri.parse(link))
      .then((HttpClientRequest request) => request.close())
      .then((HttpClientResponse response) =>
          response.pipe(new File(name).openWrite())));
}

String toCamelCase(String str) {
  RegExp exp = new RegExp(
      r'[A-Z]{2,}(?=[A-Z][a-z]+[0-9]*|\b)|[A-Z]?[a-z]+[0-9]*|[A-Z]|[0-9]+');
  Iterable<Match> matches = exp.allMatches(str);
  if (matches.isEmpty) return '';
  String res = '';
  for (Match m in matches) {
    String? match = m.group(0);
    if (match == null) {
      throw 'unexpected mismatch';
    }
    res +=
        match.substring(0, 1).toUpperCase() + match.substring(1).toLowerCase();
  }
  return res.substring(0, 1).toLowerCase() + res.substring(1);
}

class IconInfo {
  final String name;
  final String identifier;
  final String codePoint;

  IconInfo(
      {required this.name, required this.codePoint, required this.identifier});
}

class MdiInfo {
  final List<IconInfo> icons;
  final String version;
  MdiInfo({required this.icons, required this.version});
}

Future<MdiInfo> readScss() {
  String? version;
  bool isIconStarted = false;
  List<IconInfo> icons = [];
  return File('./tool/_variables.scss').readAsLines().then((lines) {
    lines.forEach((line) {
      if (version == null) {
        RegExpMatch? match = RegExp(r'version:\s+"(.+)"\s').firstMatch(line);
        if (match != null && match.group(1) != null) {
          version = match.group(1);
        }
      }
      if (!isIconStarted) {
        // is the open parenthesis, where icons start next line
        Iterable<Match> matches = RegExp(r'mdi-icons:\s\(').allMatches(line);
        if (matches.isNotEmpty) {
          isIconStarted = true;
        }
      } else {
        // is the close parenthesis, where icons are all loaded.
        bool isEndOfIcons = line.indexOf(')') >= 0;
        if (!isEndOfIcons) {
          RegExpMatch? match =
              RegExp(r'"([a-z0-9-]+)"\:\s+([0-9A-F]+)').firstMatch(line);
          if (match != null) {
            String? iconName = match.group(1);
            if (iconName == null) {
              throw 'missing icon name';
            }
            String iconIdentifier = toCamelCase(iconName);
            if (reversedKeywords.contains(iconIdentifier)) {
              iconIdentifier += 'Icon';
            }
            String? codePoint = match.group(2);
            if (codePoint == null) {
              throw 'missing code point';
            }
            codePoint = codePoint.toLowerCase();
            icons.add(IconInfo(
                name: iconName,
                identifier: iconIdentifier,
                codePoint: codePoint));
          }
        }
      }
    });
    if (version == null) {
      throw 'missing version';
    }
    return MdiInfo(icons: icons, version: version!);
  });
}

Future generateCode(
    {required String template,
    required String dest,
    required MdiInfo info}) async {
  String templateFile = await File(template).readAsString();
  RegExpMatch? match = RegExp(r'<%(.*)%>').firstMatch(templateFile);
  if (match != null) {
    String? placeholder = match.group(0);
    if (placeholder == null) {
      throw 'missing placeholder';
    }
    String? templateStatment = match.group(1);
    if (templateStatment == null) {
      throw 'missing templateStatment';
    }
    String generated = templateFile.replaceAll(
        placeholder,
        info.icons.map((icon) {
          return templateStatment
              .replaceAll('__ICON_NAME__', icon.identifier)
              .replaceAll('__ORIGINAL_ICON_NAME__', icon.name)
              .replaceAll('__CODE_POINT__', '0x${icon.codePoint}');
        }).join('\n'));
    await File(dest).writeAsString(generated);
  }
}

main() async {
  print('downloading latest materialdesignicons');
  await download(fontFile, './tool/materialdesignicons-webfont.ttf');
  await download(icons, './tool/_variables.scss');
  print('parsing');
  var info = await readScss();
  print('generating');
  await generateCode(
    template: './tool/material_design_icons_flutter.dart.template',
    dest: './lib/material_design_icons_flutter.dart',
    info: info,
  );
  await generateCode(
    template: './tool/icon_map.dart.template',
    dest: './lib/icon_map.dart',
    info: info,
  );
  File('./tool/materialdesignicons-webfont.ttf')
      .renameSync('./lib/fonts/materialdesignicons-webfont.ttf');
  File('./tool/_variables.scss').deleteSync();
  var spec = File('./pubspec.yaml').readAsStringSync();
  RegExpMatch? match =
      RegExp(r'version:\s(\d+)\.(\d+)\.(\d+)').firstMatch(spec);
  if (match == null) {
    throw 'no version in spec';
  }
  var currentVersion = match[3];
  var latestVersion = info.version.replaceAll('.', '');
  print(
      'done, latest version: ${info.version}, need publish: ${currentVersion != latestVersion}');
  exit(0);
}
