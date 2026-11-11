# material_design_icons_flutter

The [Material Design Icons](https://materialdesignicons.com/) Icon pack available as set of Flutter Icons.

Based on Material Design Icons 7.2.96. See a [web demo](https://ziofat.github.io/material_design_icons_flutter/) build with this package.

👍 Like us on [pub.dev](https://pub.dev/packages/material_design_icons_flutter)!

## Installation

In the `dependencies:` section of your `pubspec.yaml`, add the following line:

```yaml
  material_design_icons_flutter: 7.0.7296
```

**WARNING**: MDI's version is based on their icons quantity, which does not strictly respect semver guide. They do try their best to keep icons in same name between minor releases but name changing may still appear. To not break your application, using a fix version in your `pubspec.yaml` is highly recommended.

## Usage

```dart
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return new IconButton(
      // Use the MdiIcons class for the IconData
      icon: new Icon(MdiIcons.sword),
      onPressed: () { print('Using the sword'); }
     );
  }
}
```

Or, if you want to access the icon by a string name, you can use `fromString` method to create one.


```dart
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class MyWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    return new IconButton(
      // Use the string name to access icons.
      icon: new Icon(MdiIcons.fromString('sword')),
      onPressed: () { print('Using the sword'); }
     );
  }
}
```

__Note__: This is not recomended because to make `fromString` work we need a map for all icon names. Using this method will not get the benefits of tree-shaking.

On flutter 1.22 and above, using `fromString` method will also cause a compile error `This application cannot tree shake icons fonts`, which can be bypass by building with `--no-tree-shake-icons`.

## Name Conversion

Some icons' names are reserved keywords in Dart (and most other languages), so they have been changed.

- `null` -> `nullIcon`
- `switch` -> `switchIcon`
- `sync` -> `syncIcon`
- `factory` -> `factoryIcon`
