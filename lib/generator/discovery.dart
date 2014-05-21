part of streamy.generator;

Api parseDiscovery(Map discovery, Map addendum) {
  var full = _mergeMaps(discovery, addendum);
  var httpConfig = new HttpConfig(discovery['name'], full['version'], full['rootUrl'], full['servicePath']);
  var api = new Api(full['name'], full['description'], httpConfig: httpConfig);

  if (full.containsKey('schemas')) {
    full['schemas']
      .keys
      .forEach((key) {
        var schema = full['schemas'][key];
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
          type.properties[name] = _parseProperty(name, property, key, api);
        });
        
        api.types[key] = type;
      });
  }
  
  if (full.containsKey('resources')) {
    full['resources']
      .keys
      .forEach((key) {
        var resource = full['resources'][key];
        var type = new Resource(key);
        if (resource.containsKey('methods')) {
          var methods = resource['methods'];
          methods.forEach((name, method) {
            var payloadType = null;
            var responseType = null;
            if (method.containsKey('request')) {
              payloadType = _parseType(method['request'], key, '${name}_Request', api);
            }
            if (method.containsKey('response')) {
              responseType = _parseType(method['response'], key, '${name}_Response', api);
            }
            var m = new Method(name, new Path(method['path']),
                method['httpMethod'], payloadType, responseType);
            type.methods[name] = m;
            if (method.containsKey('parameters')) {
              method['parameters'].forEach((pname, param) {
                m.parameters[pname] = _parseProperty(pname, param, key, api);
              });
            }
          });
        }
        api.resources[key] = type;
      });
  }
  return api;
}

Field _parseProperty(String name, Map property, String containerName, Api api) {
  var desc = "";
  if (property.containsKey('description')) {
    desc = property['description'];
  }
  var location = '';
  if (property.containsKey('location')) {
    location = property['location'];
  }
  return new Field(name, desc, _parseType(property, containerName, name, api), location);
}

/// Process a type.
TypeRef _parseType(Map type, String containerName, String propertyName, Api api) {
  var ref = const TypeRef.any();
  if (type.containsKey('\$ref')) {
    ref = new TypeRef.schema(type['\$ref']);
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
              ref = const TypeRef.double();
              break;
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
        ref = new TypeRef.list(_parseType(type['items'], containerName, propertyName, api));
        break;
      case 'object':
        var schemaName = '${containerName}_$propertyName';
        ref = new TypeRef.schema(schemaName);
        var schema = new Schema(schemaName);
        if (type.containsKey('properties')) {
          type['properties'].forEach((name, property) {
            schema.properties[name] = _parseProperty(name, property, schemaName, api);
          });
        }
        api.types[schemaName] = schema;
        break;
      default:
        throw new Exception('Unknown type: ${type["type"]}');
    }
  }
  if (type.containsKey('repeated') && type['repeated']) {
    ref = new TypeRef.list(ref);
  }
  return ref;
}
