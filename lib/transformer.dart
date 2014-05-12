library streamy.transformer;

import 'package:barback/barback.dart';

class YamlTransformer extends Transformer {
  
  YamlTransformer.asPlugin();
  
  String get allowedExtensions => '.streamy.yaml .mustache';
  
  Future isPrimary(Asset asset) {
    return asset.path.endsWith('.streamy.yaml');
  }
  
  Future apply(Transform transform) {
    
  }
}