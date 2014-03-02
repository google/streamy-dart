/**
 * WARNING: Experimental!
 *
 * Streamy transformer for pub. Generates API clients on-the-fly.
 *
 * Usage:
 *
 * In `pubspec.yaml` of your project add the following
 *
 * ```
 * transformers:
 * - streamy/generator/transformer
 * ```
 *
 * Place the discovery file in the `asset` folder of your project.
 *
 * Import the client like this:
 *
 * ```
 * import 'package:YOUR_PROJECT_NAME/DISCOVERY_FILENAME.dart';
 * ```
 */
library streamy.transformer;

import 'dart:async';
import 'dart:io';
import 'package:barback/barback.dart';
import 'package:streamy/generator.dart';

class StreamyTransformer extends Transformer
    implements DeclaringTransformer {

  StreamyTransformer.asPlugin() {
    print('[streamy] StreamyTransformer initialized');
  }

  // TODO: use extension '.api.json' when dartbug.com/17167 is fixed.
  @override
  String get allowedExtensions => '.json';

  @override
  Future apply(Transform transform) {
    var discoveryAsset = transform.primaryInput;
    var discoveryAssetId = discoveryAsset.id;

    // TODO: remove when allowedExtensions is fixed
    if (!discoveryAssetId.path.endsWith('.api.json')) {
      return new Future.value(null);
    }

    print('[streamy] Generating API client for ${discoveryAssetId}');
    return discoveryAsset
      .readAsString()
      .then((json) => _generateClient(discoveryAssetId, json, transform));
  }

  @override
  Future declareOutputs(DeclaringTransform transform) {
    _computeAssets(transform.primaryInput.id)
      .map((a) => a.id)
      .forEach(transform.declareOutput);
    return new Future.value(null);
  }
}

Future _generateClient(AssetId discoveryAssetId, String discoveryJson,
                       Transform transform) {
  var coreName = _computeCoreName(discoveryAssetId);
  var discovery = new Discovery.fromJsonString(discoveryJson);
  var outAssets = _computeAssets(transform.primaryInput.id);
  var rootOut = outAssets[0];
  var resourceOut = outAssets[1];
  var requestOut = outAssets[2];
  var objectOut = outAssets[3];
  var templateDir = new Directory('asset/templates');

  // TODO: can barback read templates directly from streamy package?
  if (!templateDir.existsSync()) {
    throw new StateError('Cannot find templates for Streamy code generator. '
                         'The templates must be placed in asset/templates. '
                         'Streamy proviles a default set of template files in '
                         'https://github.com/google/streamy-dart/tree/master/templates. '
                         'Actual error:\nDirectory not found ${templateDir.absolute}');
  }
  var templateProvider = new DefaultTemplateProvider(templateDir.path);

  var importBase = 'package:streamy/$coreName';

  emitCode(new EmitterConfig(
      discovery,
      templateProvider,
      rootOut.sink,
      resourceOut.sink,
      requestOut.sink,
      objectOut.sink,
      // TODO: add addendum when barback supports optional inputs: dartbug.com/17225
      addendumData: {},
      fileName: importBase));

  [rootOut, resourceOut, requestOut, objectOut].forEach((_OutAsset a) {
    var asset = new Asset.fromString(a.id, a.sink.toString());
    transform.addOutput(asset);
  });

  return null;
}

List<_OutAsset> _computeAssets(AssetId discoveryAssetId) {
  var basePath = _computeBasePath(discoveryAssetId);
  var pkg = discoveryAssetId.package;
  return [
    new _OutAsset(pkg, '${basePath}.dart'),
    new _OutAsset(pkg, '${basePath}_resources.dart'),
    new _OutAsset(pkg, '${basePath}_requests.dart'),
    new _OutAsset(pkg, '${basePath}_objects.dart'),
  ];
}

String _computeBasePath(AssetId discoveryAssetId) =>
    'lib/${_computeCoreName(discoveryAssetId)}';

String _computeCoreName(AssetId discoveryAssetId) {
  var path = discoveryAssetId.path;
  return path.substring(6, path.length - 9);
}

class _OutAsset  {
  final AssetId id;
  final sink = new StringBuffer();
  _OutAsset(String pkg, String outAssetPath)
      : id = new AssetId(pkg, outAssetPath);
}
