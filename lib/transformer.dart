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
 * Import the client like this:
 *
 * ```
 * import 'package:YOUR_PROJECT_NAME/DISCOVERY_FILENAME.dart';
 * ```
 */
library streamy.transformer;

import 'dart:async';
import 'dart:convert';
import 'package:barback/barback.dart';
import 'package:quiver/iterables.dart';
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

    var filebase = discoveryAssetId.path
        .substring(0, discoveryAssetId.path.length - 9);
    var addendumAssetId = new AssetId(
        discoveryAssetId.package,
        '${filebase}.addendum.json');
    // TODO: Test that the transformer is called again when addendum appears on
    //       and disappears from the FS. This might be fixed as part of
    //       http://dartbug.com/17225.
    return transform.getInput(addendumAssetId)
      .catchError((e) {
        // TODO: Uncomment when http://dartbug.com/17225 is fixed
        //if (e is! AssetNotFoundException) throw e;
        // Addendum not found.
        return null;
      })
      .then((Asset addendumAsset) {
        var addendumMsg = addendumAsset == null
            ? ' without addendum'
            : ' with addendum ${addendumAssetId}';
        print('[streamy] Generating API client for ${discoveryAssetId}'
              '${addendumMsg}');
        return Future.wait([
          discoveryAsset.readAsString(),
          addendumAsset == null
              ? new Future.value(null)
              : addendumAsset.readAsString(),
          _loadTemplates(transform),
        ]).then((res) => _generateClient(discoveryAssetId, transform,
            res[0], res[1], res[2]));
      });
  }

  @override
  Future declareOutputs(DeclaringTransform transform) {
    _computeAssets(transform.primaryInput.id)
      .map((a) => a.id)
      .forEach(transform.declareOutput);
    return new Future.value(null);
  }
}

Future _generateClient(AssetId discoveryAssetId,
                       Transform transform,
                       String discoveryJson,
                       String addendumJson,
                       TemplateProvider templateProvider) {
  var coreName = _computeCoreName(discoveryAssetId);
  var discovery = new Discovery.fromJsonString(discoveryJson);
  var addendumData = const {};
  if (addendumJson != null) {
    addendumData = JSON.decode(addendumJson);
  }
  var outAssets = _computeAssets(transform.primaryInput.id);
  var rootOut = outAssets[0];
  var resourceOut = outAssets[1];
  var requestOut = outAssets[2];
  var objectOut = outAssets[3];
  var importBase = 'package:streamy/$coreName';

  emitCode(new EmitterConfig(
      discovery,
      templateProvider,
      rootOut.sink,
      resourceOut.sink,
      requestOut.sink,
      objectOut.sink,
      addendumData: addendumData,
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

Future<TemplateProvider> _loadTemplates(Transform transform) {
  const templateNames = const [
    'client_header',
    'object',
    'object_file_header',
    'pubspec',
    'request',
    'request_file_header',
    'resource',
    'resource_file_header',
    'root'
  ];
  var futures = templateNames.map((String templateName) {
    var templateAssetId =
        new AssetId('streamy', 'asset/${templateName}.mustache');
    return transform.readInputAsString(templateAssetId);
  }).toList(growable: false);
  return Future.wait(futures).then((contents) {
    var templates = {};
    for (var nameContent in zip([templateNames, contents])) {
      var templateName = nameContent[0];
      var templateContent = nameContent[1];
      templates[templateName] = templateContent;
    }
    return new _InMemoryTemplateProvider(templates);
  });
}

class _InMemoryTemplateProvider implements TemplateProvider {
  final Map<String, String> templates;

  _InMemoryTemplateProvider(this.templates);

  String get sourceOfTemplates => 'Streamy transformer';

  String operator[](String templateName) => templates[templateName];
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
