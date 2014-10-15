library streamy.generator.template_loader;

import 'dart:async';
import 'dart:io' as io;
import 'package:mustache/mustache.dart' as mustache;

/// The location of templates bundled with Streamy. It assumes Streamy is run
/// from the root of the project. This value is used by default if no specific
/// value is provided.
const String DEFAULT_TEMPLATE_DIR = 'lib/templates';

/// Reads template source from files named {templateName}.mustache.
class DefaultTemplateLoader implements TemplateLoader {
  final String templateDir;

  DefaultTemplateLoader(this.templateDir);

  factory DefaultTemplateLoader.defaultInstance() {
    return new DefaultTemplateLoader(DEFAULT_TEMPLATE_DIR);
  }

  @override
  Future<mustache.Template> load(String templateName) {
    var templateFile =
        new io.File('${templateDir}/${templateName}.mustache');
    return templateFile.readAsString()
      .then(mustache.parse);
  }
}

abstract class TemplateLoader {

  factory TemplateLoader.fromDirectory(String path) {
    return new FileTemplateLoader(path);
  }

  Future<mustache.Template> load(String name);
}

class FileTemplateLoader implements TemplateLoader {
  final io.Directory path;

  FileTemplateLoader(String path) : path = new io.Directory(path).absolute;

  Future<mustache.Template> load(String name) {
    var f = new io.File("${path.path}/$name.mustache");
    if (!f.existsSync()) {
      return null;
    }
    return f.readAsString().then(mustache.parse);
  }
}
