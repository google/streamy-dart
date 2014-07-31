part of streamy.generator;

/// Google API discovery document in an object-oriented format.
class Discovery {
  /// Objects and their properties
  final Map<String, TypeDescriptor> schemas;
  /// Resources and their methods
  final List<Resource> resources;
  /// API name
  final String name;
  /// API version
  final String version;
  /// API description
  final String description;
  /// Service path
  final String servicePath;
  /// Links to documentation web-site
  final String documentationLink;

  Discovery(
      this.schemas,
      this.resources,
      this.name,
      this.version,
      this.description,
      this.servicePath,
      this.documentationLink);

  /// Creates a [Discovery] from JSON.  Mixes in schemas from addendumData, if provided.
  factory Discovery.fromJsonString(String jsonString, {Map<String, Map> addendumData}) {
    Map jsDiscovery = JSON.decode(jsonString);
    Map addendumSchemas = addendumData != null && addendumData.containsKey('schemas') ?
        addendumData['schemas'] : {};
    return new Discovery(
      extractNameTypePairs(jsDiscovery['schemas']..addAll(addendumSchemas)),
      extractResources(jsDiscovery['resources']),
      jsDiscovery['name'],
      jsDiscovery.containsKey('version') ? jsDiscovery['version'] : 'v1',
      jsDiscovery['description'],
      jsDiscovery['servicePath'],
      jsDiscovery['documentationLink']
    );
  }
}

/// Takes plain JSON map of names and type descriptors and extracts objectified
/// version.
Map<String, TypeDescriptor> extractNameTypePairs(Map<String, Map> jsNameTypePairs) {
  if (jsNameTypePairs == null) {
    return {};
  }
  var result = <String, TypeDescriptor>{};
  jsNameTypePairs.forEach((String name, Map jsTypeDescriptor) {
    result[name] = new TypeDescriptor.fromJsonObject(jsTypeDescriptor);
  });
  return result;
}

List<Resource> extractResources(Map jsResources) {
  if (jsResources == null) {
    return [];
  }
  List<Resource> result = [];
  jsResources.forEach((String name, Map jsResource) {
    result.add(new Resource.fromJsonObject(name, jsResource));
  });
  return result;
}

class TypeDescriptor {
  final String id;
  final String kind;
  final String description;
  final DescriptorType type;
  final String ref;
  final String format;
  final Map<String, TypeDescriptor> properties;
  final TypeDescriptor items;
  final TypeDescriptor additionalProperties;

  TypeDescriptor._private(
      this.id,
      this.kind,
      this.description,
      this.type,
      this.ref,
      this.format,
      this.properties,
      this.items,
      this.additionalProperties
  );

  factory TypeDescriptor.fromJsonObject(Map jsDescriptor) {
    if (jsDescriptor == null) {
      return null;
    }
    DescriptorType type;
    if (jsDescriptor.containsKey('\$ref')) {
      type = REF_TYPE;
    } else {
      type = DESCRIPTOR_TYPES[jsDescriptor['type']];
    }
    return new TypeDescriptor._private(
        jsDescriptor['id'],
        extractKind(jsDescriptor),
        jsDescriptor['description'],
        type,
        jsDescriptor['\$ref'],
        jsDescriptor['format'],
        extractNameTypePairs(jsDescriptor['properties']),
        new TypeDescriptor.fromJsonObject(jsDescriptor['items']),
        new TypeDescriptor.fromJsonObject(jsDescriptor['additionalProperties'])
    );
  }
}

String extractKind(Map jsDescriptor) {
  Map kindMap = jsDescriptor['kind'];
  if (kindMap != null) {
    String type = kindMap['type'];
    if (type == STRING_TYPE.name) {
      String dflt = kindMap['default'];
      if (dflt != null) {
        return dflt;
      } else {
        print('WARNING: default value for \'kind\' is missing');
      }
    } else {
      print('WARNING: \'kind\' property expected to be of type ' +
          '\'${STRING_TYPE.name}\' but was \'${type}\'');
    }
  }
  return null;
}

/// Enumeration of all supported built-in types
const ANY_TYPE = const DescriptorType('any', dartType: 'dynamic');
const ARRAY_TYPE = const DescriptorType('array');
const BOOLEAN_TYPE = const DescriptorType('boolean', dartType: 'bool');
const INTEGER_TYPE = const DescriptorType('integer', dartType: 'int');
const NUMBER_TYPE = const DescriptorType('number', dartType: 'num');
const NULL_TYPE = const DescriptorType('null', dartType: 'Object');
const REF_TYPE = const DescriptorType('ref');
const OBJECT_TYPE = const DescriptorType('object');
const STRING_TYPE = const DescriptorType('string', dartType: 'String');
const Map<String, DescriptorType> DESCRIPTOR_TYPES =
    const <String, DescriptorType>{
      'any': ANY_TYPE,
      'array': ARRAY_TYPE,
      'boolean': BOOLEAN_TYPE,
      'integer': INTEGER_TYPE,
      'number': NUMBER_TYPE,
      'null': NULL_TYPE,
      'object': OBJECT_TYPE,
      'ref': REF_TYPE,
      'string': STRING_TYPE,
    };

/// One of built-in types
class DescriptorType {
  final String name;
  final String dartType;
  const DescriptorType(this.name, {this.dartType: null});

  String toString() => name;
}

/// RESTful resource
class Resource {
  final String name;
  final List<Method> methods;
  /// Sub-resources
  final List<Resource> resources;

  Resource._private(this.name, this.methods, this.resources);

  factory Resource.fromJsonObject(String name, Map jsResource) {
    return new Resource._private(
        name,
        extractMethods(jsResource['methods']),
        extractResources(jsResource['resources']));
  }
}

List<Method> extractMethods(Map jsMethods) {
  List<Method> result = [];
  if (jsMethods == null) return result;
  jsMethods.forEach((String name, Map jsSchema) {
    result.add(new Method.fromJsonObject(name, jsSchema));
  });
  return result;
}

class HttpMethod {
  final String name;
  const HttpMethod(this.name);
}

const HTTP_GET = const HttpMethod('GET');
const HTTP_POST = const HttpMethod('POST');
const HTTP_PUT = const HttpMethod('PUT');
const HTTP_DELETE = const HttpMethod('DELETE');
const HTTP_PATCH = const HttpMethod('PATCH');

const Map<String, HttpMethod> HTTP_METHODS = const {
  'GET': HTTP_GET,
  'POST': HTTP_POST,
  'PUT': HTTP_PUT,
  'DELETE': HTTP_DELETE,
  'PATCH': HTTP_PATCH,
};

class Method {
  final String id;
  final String path;
  final String name;
  final TypeDescriptor request;
  final TypeDescriptor response;
  final HttpMethod httpMethod;
  final String description;
  final Map<String, Parameter> parameters;
  final List<String> parameterOrder;

  Method._private(
      this.id,
      this.path,
      this.name,
      this.request,
      this.response,
      this.httpMethod,
      this.description,
      this.parameters,
      this.parameterOrder
  );

  factory Method.fromJsonObject(String name, Map jsMethod) {
    TypeDescriptor req = new TypeDescriptor.fromJsonObject(jsMethod['request']);
    TypeDescriptor resp = new TypeDescriptor.fromJsonObject(jsMethod['response']);
    var strHttpMethod = jsMethod['httpMethod'];
    var httpMethod = HTTP_METHODS[strHttpMethod];
    if (httpMethod == null) {
      throw new ApigenException('Unsupported HTTP method ${strHttpMethod}');
    }
    return new Method._private(
        jsMethod['id'],
        jsMethod['path'],
        name,
        req,
        resp,
        httpMethod,
        jsMethod['description'],
        extractParameters(jsMethod['parameters']),
        jsMethod['parameterOrder']
    );
  }
}

Map<String, Parameter> extractParameters(Map<String, Map> jsParams) {
  if (jsParams == null) {
    return {};
  }
  var result = <String, Parameter>{};
  jsParams.forEach((String name, Map jsParamDescriptor) {
    var type = new TypeDescriptor.fromJsonObject(jsParamDescriptor);
    var location = LOCATIONS[jsParamDescriptor['location']];
    var repeated = jsParamDescriptor['repeated'] == true;
    result[name] = new Parameter(name, type, location, repeated);
  });
  return result;
}

class ParameterLocation {
  final String name;
  const ParameterLocation(this.name);
}

const LOCATION_PATH = const ParameterLocation('path');
const LOCATION_QUERY = const ParameterLocation('query');

const Map<String, ParameterLocation> LOCATIONS = const {
  'path': LOCATION_PATH,
  'query': LOCATION_QUERY,
};

class Parameter {
  final String name;
  final TypeDescriptor type;
  final ParameterLocation location;
  final bool repeated;

  Parameter(this.name, this.type, this.location, this.repeated);
}
