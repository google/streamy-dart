library streamy.generator.transformer.test;

import 'dart:async';
import 'dart:convert';
import 'dart:io' as io;
import 'package:barback/barback.dart';
import 'package:quiver/iterables.dart';
import 'package:streamy/generator/transformer.dart';
import 'package:unittest/unittest.dart';
import '../project.dart';
import '../test_data.dart';

main(List<String> args) {
  group('StreamyTransformer', () {
    test('should instantiate', () {
      new StreamyTransformer.asPlugin();
    });
    test('should allow json extensions', () {
      expect(new StreamyTransformer.asPlugin().allowedExtensions, '.json');
    });
    test('should declare outputs', () {
      var fakeDiscovery = new Asset.fromString(
          new AssetId('test', 'asset/urlshortener.api.json'), '');
      var fake = new FakeDeclaringTransform(fakeDiscovery);
      new StreamyTransformer.asPlugin().declareOutputs(fake);

      var expectedOutputs = enumerate([
        'lib/urlshortener.dart',
        'lib/urlshortener_objects.dart',
        'lib/urlshortener_resources.dart',
        'lib/urlshortener_requests.dart',
      ]);

      expect(fake.declaredOutputs, hasLength(expectedOutputs.length));
      expectedOutputs.forEach((expected) {
        expect(fake.declaredOutputs,
            contains(new AssetId('test', expected.value)));
      });
    });
    test('should emit outputs', () {
      var fakeDiscovery = new Asset.fromString(
          new AssetId('test', 'asset/urlshortener.api.json'),
          SAMPLE_DISCOVERY);
      var fake = new FakeTransform(fakeDiscovery, args);
      new StreamyTransformer.asPlugin().apply(fake).then(expectAsync1((_) {
        var expectedOutputs = enumerate([
          'lib/urlshortener.dart',
          'lib/urlshortener_objects.dart',
          'lib/urlshortener_resources.dart',
          'lib/urlshortener_requests.dart',
        ]);

        expect(fake.outputs, hasLength(expectedOutputs.length));

        fake.outputs.forEach((output) {
          output.readAsString().then(expectAsync1((content) {
            expect(content, isNot(isEmpty));
          }));
        });

        expectedOutputs.forEach((expected) {
          expect(fake.outputs.map((o) => o.id),
              contains(new AssetId('test', expected.value)));
        });
      }));
    });
  });
}

class FakeDeclaringTransform implements DeclaringTransform {

  var declaredOutputs = <AssetId>[];

  @override Asset primaryInput;

  FakeDeclaringTransform(this.primaryInput);

  @override
  void declareOutput(AssetId id) {
    declaredOutputs.add(id);
  }

  @override
  Future<Asset> getInput(AssetId id) {
    return null;
  }

  @override
  TransformLogger get logger => null;

  @override
  Stream<List<int>> readInput(AssetId id) {
    return null;
  }

  @override
  Future<String> readInputAsString(AssetId id, {Encoding encoding}) {
    return null;
  }
}


class FakeTransform implements Transform {

  var outputs = <Asset>[];
  final List<String> args;

  @override Asset primaryInput;

  FakeTransform(this.primaryInput, this.args);

  @override
  void addOutput(Asset asset) {
    outputs.add(asset);
  }

  @override
  Future<Asset> getInput(AssetId id) {
    return null;
  }

  @override
  TransformLogger get logger => null;

  @override
  Stream<List<int>> readInput(AssetId id) {
    fail('Should not have reached this code');
    return null;
  }

  @override
  Future<String> readInputAsString(AssetId id, {Encoding encoding}) {
    io.File templateFile = new io.File('${projectRootDir(args)}/${id.path}');
    return new Future.value(templateFile.readAsStringSync());
  }
}
