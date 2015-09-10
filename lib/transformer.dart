/*
 * Streamy Barback transformers.
 *
 * To use add this to your pubspec.yaml:
 *
 *     transformers:
 *     - streamy
 *
 * If `protoc` is not in your path specify the absolute path like this:
 *
 *     transformers:
 *     - streamy
 *         path_to_prococ: /path/to/protoc
 */
library streamy.transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:mustache/mustache.dart' as mustache;
import 'package:streamy/generator.dart';
import 'package:streamy/generator/config.dart';
import 'package:streamy/generator/dart.dart';
import 'package:streamy/generator/emitter.dart';
import 'package:streamy/generator/template_loader.dart';
import 'package:streamy/mixologist.dart' as mixologist;
import 'package:yaml/yaml.dart' as yaml;
import 'package:quiver/async.dart';

import 'src/fs/transform_fs.dart';

class StreamyTransformerGroup implements TransformerGroup {

  @override
  final Iterable<Iterable> phases;

  StreamyTransformerGroup.asPlugin(BarbackSettings settings)
      : phases = _createPhases(settings);
}

Iterable<Iterable> _createPhases(BarbackSettings settings) {
  return [
    [new MixologistYamlTransformer()],
    [new StreamyYamlTransformer(settings)],
  ];
}

class StreamyYamlTransformer extends Transformer {
  final String _pathToProtoc;

  StreamyYamlTransformer(BarbackSettings settings)
      : _pathToProtoc = settings.configuration['path_to_protoc'];

  String get allowedExtensions => '.streamy.yaml';
  
  Future<bool> isPrimary(AssetId asset) =>
    new Future.value(asset.path.endsWith('.streamy.yaml'));

  Future apply(Transform transform) => transform
    .primaryInput
    .readAsString()
    .then(yaml.loadYaml)
    .then(parseConfigOrDie)
    .then((config) => emitterFromTemplateLoader(config,
        new AssetTemplateLoader(transform)))
    .then((Emitter emitter) => apiFromConfig(
        emitter.config,
        pathPrefix: prefixFrom(transform.primaryInput.id),
        fileReader: (path) => transform
            .getInput(new AssetId(transform.primaryInput.id.package, path))
            .then((input) => input.readAsString()),
        protoc: _pathToProtoc)
            .then(emitter.process))
    .then((StreamyClient client) {
      _maybeOutput(transform, client.root, '', client.config.outputPrefix);
      _maybeOutput(transform, client.resources, '_resources',
          client.config.outputPrefix);
      _maybeOutput(transform, client.requests, '_requests',
          client.config.outputPrefix);
      _maybeOutput(transform, client.objects, '_objects',
          client.config.outputPrefix);
      _maybeOutput(transform, client.dispatch, '_dispatch',
          client.config.outputPrefix);
    });

  void _maybeOutput(Transform transform, DartFile file, String name,
      String outputPrefix) {
    if (file == null) {
      return;
    }
    var id = new AssetId(transform.primaryInput.id.package,
        '${prefixFrom(transform.primaryInput.id)}$outputPrefix$name.dart');
    transform.addOutput(new Asset.fromString(id, file.render()));
  }
}

class AssetTemplateLoader implements TemplateLoader {
  final Transform transform;
  
  AssetTemplateLoader(this.transform);
  
  Future<mustache.Template> load(String name) => transform
    .getInput(new AssetId('streamy', 'lib/templates/$name.mustache'))
    .then((asset) => asset.readAsString())
    .then((source) => new mustache.Template(source, htmlEscapeValues: false));
}

class MixologistYamlTransformer extends Transformer {

  MixologistYamlTransformer();
  
  String get allowedExtensions => '.mixologist.yaml';

  Future apply(Transform transform) {
    mixologist.Config config;
    return transform
      .primaryInput
      .readAsString()
      .then((String configString) {
        config = mixologist.parseConfig(yaml.loadYaml(configString));
      })
      .then((_) =>
          mixologist.mix(config, new TransformFileSystem(transform)))
      .then((code) {
        var id = new AssetId(transform.primaryInput.id.package,
        '${prefixFrom(transform.primaryInput.id)}${config.output}');
        transform.addOutput(new Asset.fromString(id, code));
      })
      .catchError((err) {
        print('STREAMY TRANSFORMER ERROR: $err');
      });
  }
}
