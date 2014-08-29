/*
 * Provides default implementations and default values.
 */
part of streamy.generator;

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
