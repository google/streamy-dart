part of streamy.traitor;

Map<String, String> unifyImports(List<Trait> traits) {
  var out = <String, String>{};
  var pathToTrait = <String, String>{};
  traits.forEach((trait) {
    trait.imports.forEach((path, alias) {
      if (out.containsKey(path) && out[path] != alias) {
        throw new ImportException(
            path, alias, trait.name, out[path], pathToTrait[path]);
      }
      out[path] = alias;
      pathToTrait[path] = trait.className;
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

class ImportException extends Exception {
  final String path;
  final String attemptedAlias;
  final String attemptedTrait;
  final String importAlias;
  final String importTrait;
  
  ImportException(this.path, this.attemptedAlias, this.attemptedTrait,
      this.importAlias, this.importTrait);
      
  String toString() => "Attempted import of '$path' as '$attemptedAlias' by " +
      "$attemptedTrait, but already imported as '$importAlias' by $importTrait";
}