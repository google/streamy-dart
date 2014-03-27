part of streamy.generator;

Api parse(Map discovery, Map addendum) {
  var full = _mergeMaps(discovery, addendum);
  var version = discovery['version'];
  var url = discovery['rootUrl'];
  var api = new Api(name, discovery['name'], version, url);

  if (discovery.containsKey('schemas')) {
    discovery['schemas']
      .keys
      .forEach((key) {
        var schema = schemas[key];
        var type = new Schema(schema['id']);
        
        var props = {};
        if (schema.containsKey('properties')) {
          props = schema['properties'];
        }
        /*
        if (schema.containsKey('additionalProperties'])) {
          params = _mergeMaps(params, schema['additionalProperties']);
        }
        */
        props.forEach((name, property) {
          type.properties[name] = _parseProperty(name, property);
        });
        
        api.types[key] = type;
      });
  }
  
  if (discovery.containsKey('resources')) {
    discovery['resources']
      .keys
      .forEach((key) {
        var resource = resources[key];
        var type = new Resource(key);
      });
  }
  return api;
}

Field _parseProperty(String name, Map property) {
  var desc = "";
  if (property.containsKey('description')) {
    desc = property['description'];
  }
  return new Field(desc, _parseType(property));
}

TypeRef _parseType(Map type) {
  var ref = const TypeRef.any();
  if (type.containsKey('\$ref')) {
    ref = new TypeRef.schema('', type['\$ref']);
  } else if (type.containsKey('type')) {
    switch (type['type']) {
      case 'string':
        ref = const TypeRef.string();
        if (type.containsKey('format')) {
          switch (type['format']) {
            case 'int64':
              ref = const TypeRef.int64();
              break;
            case 'double':
              ref = const TypeRef.int64();
            default:
          }
        }
        break;
      case 'integer':
        ref = const TypeRef.integer();
        break;
      case 'number':
        ref = const TypeRef.number();
        break;
      case 'boolean':
        ref = const TypeRef.boolean();
        break;
      case 'array':
        ref = new TypeRef.list(_parseType(type['items']));
        break;
      default:
    }
  }
  return ref;
}

Map _mergeMaps(Map a, Map b) {
  var out = {};
  a.keys.forEach((key) {
    if (!b.containsKey(key)) {
      out[key] = a[key];
    } else {
      var aVal = a[key];
      var bVal = b[key];
      if (bVal == null || aVal == null) {
        out[key] = aVal;
      } else if (aVal is Map && bVal is Map) {
        out[key] = _mergeMaps(aVal, bVal)
      } else {
        out[key] = bVal;
      }
    }
  });
  return out;
}