/*
 * Provides default implementations and default values.
 */
part of streamy.generator;

/// The location of templates bundled with Streamy. It assumes Streamy is run
/// from the root of the project. This value is used by default if no specific
/// value is provided.
const String DEFAULT_TEMPLATE_DIR = 'asset';

/// Reads template source from files named {templateName}.mustache.
class DefaultTemplateProvider implements TemplateProvider {
  final String templateDir;

  DefaultTemplateProvider(this.templateDir);

  factory DefaultTemplateProvider.defaultInstance() {
    return new DefaultTemplateProvider(DEFAULT_TEMPLATE_DIR);
  }

  String get sourceOfTemplates => 'folder ${templateDir}';

  String operator[](String templateName) {
    io.File templateFile =
        new io.File('${templateDir}/${templateName}.mustache');
    return templateFile.readAsStringSync();
  }
}
