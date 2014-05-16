library streamy.transformer;

import 'dart:async';
import 'package:barback/barback.dart';
import 'package:mustache/mustache.dart' as mustache;
import 'package:streamy/generator.dart';
import 'package:yaml/yaml.dart' as yaml;

class YamlTransformer extends Transformer {
  
  YamlTransformer.asPlugin();
  
  String get allowedExtensions => '.streamy.yaml';
  
  Future<bool> isPrimary(Asset asset) =>
    new Future.value(asset.id.path.endsWith('.streamy.yaml'));

  Future apply(Transform transform) => transform
    .primaryInput
    .readAsString()
    .then(yaml.loadYaml)
    .then(parseConfigOrDie)
    .then((config) => Emitter.fromTemplateLoader(config, new AssetTemplateLoader(transform)))
    .then((emitter) => apiFromConfig(emitter.config, pathPrefix: _prefixFrom(transform.primaryInput.id.path), fileReader: (path) => transform
      .getInput(new AssetId(transform.primaryInput.id.package, path))
      .then((input) => input.readAsString()))
      .then(emitter.process))
    .then((client) {
      _maybeOutput(transform, client.root, '', client.config.outputPrefix);
      _maybeOutput(transform, client.resources, '_resources', client.config.outputPrefix);
      _maybeOutput(transform, client.requests, '_requests', client.config.outputPrefix);
      _maybeOutput(transform, client.objects, '_objects', client.config.outputPrefix);
      _maybeOutput(transform, client.dispatch, '_dispatch', client.config.outputPrefix);
    });
  
  void _maybeOutput(Transform transform, DartFile file, String name, String outputPrefix) {
    if (file == null) {
      return;
    }
    var id = new AssetId(transform.primaryInput.id.package, '${_prefixFrom(transform.primaryInput.id.path)}$outputPrefix$name.dart');
    transform.addOutput(new Asset.fromString(id, file.render()));
  }
  
  String _prefixFrom(String path) => (path.split('/')..removeLast()..add('')).join('/');
}

/*
.then((emitter) => apiFromConfig(emitter.config, fileReader: (path) {
      print("Reading: $path");
      return transform.getInput(new AssetId(transform.primaryInput.id.package, path));
    })
      .then(emitter.process))
      */
class AssetTemplateLoader implements TemplateLoader {
  final Transform transform;
  
  AssetTemplateLoader(this.transform);
  
  Future<mustache.Template> load(String name) => transform
    .getInput(new AssetId('streamy', 'lib/templates/$name.mustache'))
    .then((asset) => asset.readAsString())
    .then(mustache.parse);
}
