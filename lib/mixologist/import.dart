part of streamy.mixologist;

Map<String, String> unifyImports(List<Mixin> mixins) {
  var out = <String, String>{};
  var pathToMixin = <String, String>{};
  mixins.forEach((mixin) {
    mixin.imports.forEach((path, alias) {
      if (out.containsKey(path) && out[path] != alias) {
        throw new ImportException(
            path, alias, mixin.name, out[path], pathToMixin[path]);
      }
      out[path] = alias;
      pathToMixin[path] = mixin.className;
    });
  });
  return out;
}

List<String> writeImports(Map<String, String> imports) {
  var out = <String>[];
  imports.forEach((path, alias) {
    if (alias != null) {
      out.add("import '$path' as $alias;");
    } else {
      out.add("import '$path';");
    }
  });
  return out;
}

class ImportException implements Exception {
  final String path;
  final String attemptedAlias;
  final String attemptedMixin;
  final String importAlias;
  final String importMixin;

  ImportException(this.path, this.attemptedAlias, this.attemptedMixin,
      this.importAlias, this.importMixin);

  String toString() => "Attempted import of '$path' as '$attemptedAlias' by " +
      "$attemptedMixin, but already imported as '$importAlias' by $importMixin";
}