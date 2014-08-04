part of streamy.generator;

Api parseServices(List<String> paths) {
  var api = new Api('example', marshalling: false);
  var i = 1;
  paths.forEach((path) => _parseServiceFile(api, path, analyzer.parseDartFile(path), i++));
  var pc = new PathConfig.prefixed('lib/', 'package:api/');
  var hc = new HierarchyConfig.fixed(new DartType('Entity', 'base', const []));
  var c = new Config(knownProperties: false);
  var emitter = new Emitter(SPLIT_LEVEL_NONE, pc, hc, c,
      new TemplateLoader.fromDirectory('templates'));
  var client = emitter.process(api);
  print(client.root.render());
}

void _parseServiceFile(Api api, String importPath, analyzer.CompilationUnit cu, int index) {
  var classes = cu
    .declarations
    .where((d) => d is analyzer.ClassDeclaration);
  
  api.imports[importPath] = 'service_$index';
  classes
    .where(_isSchemaClass)
    .map((clazz) => clazz.name.name)
    .forEach((name) {
      var type = new Schema(name);
      type.mixins.add(new TypeRef.external(name, 'service_$index'));
      api.types[name] = type;
    });
  
  classes
    .where(_isServiceClass)
    .forEach((clazz) => _parseService(api, importPath, clazz));
}

void _parseService(Api api, String importPath, analyzer.ClassDeclaration clazz) {
  var res = new Resource(clazz.name.name);
  api.resources[res.name] = res;
  clazz
    .members
    .where((d) => d is analyzer.MethodDeclaration)
    .where((m) => m.returnType != null)
    .where((m) => m.returnType.name.name == 'Future')
    .forEach((m) {
      var rt = m.returnType.typeArguments.arguments[0].name.name;
      var ref = new TypeRef.external(rt, importPath);
      var method = new Method(m.name.name, new Path('/'), '', null, ref);
      res.methods[method.name] = method;
      // Need a request class for the method.
      var name = '${res.name}${toProperIdentifier(m.name.name)}Request';
      m
        .parameters
        .parameters
        .where((p) => p is analyzer.SimpleFormalParameter)
        .forEach((p) {
          var name = p.identifier.name;
          method.parameters[name] = new Field(name, '', const TypeRef.string(), '');
        });
    });
}

bool _isSchemaClass(analyzer.ClassDeclaration clazz) => clazz
  .members
  .where((d) => d is analyzer.ConstructorDeclaration)
  .isEmpty;
  
bool _isServiceClass(analyzer.ClassDeclaration clazz) {
  var methods = clazz
    .members
    .where((d) => d is analyzer.MethodDeclaration);
  return methods.isNotEmpty && methods
    .map((m) {
      if (m.returnType == null) {
        return "";
      }
      return m.returnType.name.name;
    })
    .every((type) => type == 'Future');
}

