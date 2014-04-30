part of streamy.generator;

// TODO(Alex): Unify all the configs.

class Config {
  
  final bool mapBackedFields;
  final String backingMapGetter;
  final String backingMapSetter;
  final bool cloneEntity;
  final bool removers;
  final bool knownMethods;
  final bool knownParameters;
  final bool knownProperties;
  
  Config({
    this.mapBackedFields: true,
    this.backingMapGetter: null,
    this.backingMapSetter: null,
    this.cloneEntity: true,
    this.removers: true,
    this.knownMethods: true,
    this.knownProperties: true,
    this.knownParameters: true
  });
}

abstract class PathConfig {
  String relativePath(String partName);
  String importPath(String libraryName);
  
  factory PathConfig.prefixed(String partPrefix, String importPrefix) {
    return new _PrefixedPathConfig(partPrefix, importPrefix);
  }
}

abstract class HierarchyConfig {
  DartType baseClassFor(String schemaName);
  
  factory HierarchyConfig.fixed(DartType base) =>
      new _FixedHierarchyConfig(base);
}

class _FixedHierarchyConfig implements HierarchyConfig {
  final DartType base;
  
  _FixedHierarchyConfig(this.base);
  
  DartType baseClassFor(String schemaName) => base;
}
  

class _PrefixedPathConfig implements PathConfig {
  final String partPrefix;
  final String importPrefix;

  _PrefixedPathConfig(this.partPrefix, this.importPrefix);

  String relativePath(String partName) => "$partPrefix$partName";
  String importPath(String libraryName) => "$importPrefix$libraryName";
}

class TemplateLoader {
  
  factory TemplateLoader.fromDirectory(String path) {
    return new FileTemplateLoader(path);
  }
  
  mustache.Template load(String name);
}

class FileTemplateLoader implements TemplateLoader {
  final String path;
  
  FileTemplateLoader(this.path);
  
  mustache.Template load(String name) {
    var f = new io.File("$path/$name.mustache");
    if (!f.existsSync()) {
      return null;
    }
    return mustache.parse(f.readAsStringSync());
  }
}
