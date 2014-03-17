library streamy.linearizer.main;

import 'dart:async';
import 'dart:io';
import 'package:streamy/traitor.dart' as traitor;


main() {
  List<String> traitInputs = [
    'base_map',
    'copy_clone',
    'observable',
    'global',
    'dot_access',
    'local',
    'immutable'
  ];

  String libraryName = 'streamy.base';
  String output = 'lib/base.dart';
  String finalClass = 'EntityBase';
  String intermediate = 'EB_';
  String baseClass = 'Object';
  
  var fnLines = [
    "void setMap(entity, map) {",
    "  entity._map = map;",
    "}",
    "",
    "Map getMap(entity) => entity._map;"
  ];
  
  Future
    .wait(
        traitInputs
          .map((name) => 'lib/traits/$name.dart')
          .map((path) => new File(path))
          .map((file) => file.openRead())
          .map((data) => data.pipe(new traitor.TraitReader()))
    ).then((traits) {
      var out = <String>[];
      out.add("library $libraryName;");
      out.add("");
      out.addAll(traitor.writeImports(traitor.unifyImports(traits)));
      out.add("");
      var target = new traitor.LinearizedTarget(finalClass, intermediate, baseClass, traits);
      out.addAll(target.linearize());
      out.add("");
      out.addAll(fnLines);
      out.add("");
      return out.join("\n");
    }).then((data) => new File("$output")
        .openWrite()
        ..write(data)
        ..close()
    ).then((_) => print("Done."));
}