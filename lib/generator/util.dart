part of streamy.generator;

String _joinParts(Iterable<String> parts) {
  bool isFirst = true;
  return parts.map((part) {
    part = _fixIllegalChars(part);
    if (!isFirst) {
      part = _capitalize(part);
    }
    isFirst = false;
    return part;
  }).join('');
}

String _makePropertyName(String name) {
  name = _fixIllegalChars(name);
  if (_ILLEGAL_PROPERTY_NAMES.contains(name)) {
    name = '\$${name}';
  }
  return name;
}

String _makeMethodName(String name) {
  name = _fixIllegalChars(name);
  if (_ILLEGAL_METHOD_NAMES.contains(name)) {
    name = '\$${name}';
  }
  return name;
}

String _makeRemoverName(String name) {
  name = _capitalize(_fixIllegalChars(name));
  return 'remove${name}';
}

String _makeHandlerName(String name) {
  name = _makeClassName(name);
  return '_handle${name}';
}

String _makeClassName(String name) {
  name = _capitalize(_fixIllegalChars(name));
  if (_ILLEGAL_CLASS_NAMES.contains(name)) {
    name = '\$${name}';
  }
  return name;
}

String _fixIllegalChars(String name) {
  if (name.length == 0) {
    throw new StateError('Empty property, schema, resource or method name');
  }

  // Make names like foo_bar_baz look like fooBarBaz
  var first = true;
  name = name
    .split('_')
    .map((piece) {
      if (first) {
        first = false;
        return piece;
      }
      if (piece.length > 1) {
        return piece.substring(0, 1).toUpperCase() + piece.substring(1);
      } else {
        return piece.toUpperCase();
      }
    })
    .join();


  // Replace bad starting character with dollar sign (it has to be public)
  if(!name.startsWith(IDENTIFIER_START)) {
    name = '\$${name.substring(1)}';
  }

  // Replace bad characters in the middle with underscore
  name = name.replaceAll(NON_IDENTIFIER_CHAR_MATCHER, '_');
  if (name.startsWith('_')) {
    name = 'clean${name}';
  }

  return name;
}

/// Turns the first letter in a string to a capital letter.
String _capitalize(String str) {
  if (str == null || str.length == 0) {
    return str;
  }
  return str[0].toUpperCase() + str.substring(1);
}

List<String> splitStringAcrossLines(String src, [int maxLen = 80]) {
  var lines = [];
  var words = src.split(' ');
  var out = new StringBuffer();
  var outLen = 0;
  words.forEach((word) {
    if (outLen + word.length + 1 <= maxLen) {
      out
        ..write(' ')
        ..write(word);
      outLen += 1 + word.length;
    } else {
      lines.add(out.toString().trim());
      out = new StringBuffer()
        ..write(word);
      outLen = word.length;
    }
  });
  lines.add(out.toString().trim());
  return lines;
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
        out[key] = _mergeMaps(aVal, bVal);
      } else {
        out[key] = bVal;
      }
    }
  });
  b.keys.forEach((key) {
    if (!a.containsKey(key)) {
      out[key] = b[key];
    }
  });
  return out;
}

/// Characters allowed as starting identifier characters. Note the absence of
/// underscore. This is because generated identifiers have to be public.
final IDENTIFIER_START = new RegExp(r'[a-zA-Z\$]');
final NON_IDENTIFIER_CHAR_MATCHER = new RegExp(r'[^a-zA-Z\d\$_]');

/// Disallowed property names.
const _ILLEGAL_PROPERTY_NAMES = const [
  // Streamy reserved symbols
  'parameters',
  'global',
  'clone',
  'patch',
  'isFrozen',
  'containsKey',
  'fieldNames',
  'remove',
  'toJson',
  'local',
  'streamyType',
  'changes',
  'deliverChanges',
  'notifyChange',
  'notifyPropertyChange',
  'hasObservers',
  'apiType',

  // Dart keywords
  'continue',
  'extends',
  'throw',
  'default',
  'rethrow',
  'true',
  'assert',
  'do',
  'false',
  'in',
  'return',
  'try',
  'break',
  'final',
  'is',
  'case',
  'else',
  'finally',
  'var',
  'catch',
  'enum',
  'for',
  'new',
  'super',
  'void',
  'class',
  'null',
  'switch',
  'while',
  'const',
  'if',
  'this',
  'with',
];

/// Disallowed method names.
const _ILLEGAL_METHOD_NAMES = const [
  'abstract',
  'continue',
  'extends',
  'throw',
  'default',
  'factory',
  'rethrow',
  'true',
  'assert',
  'do',
  'false',
  'in',
  'return',
  'try',
  'break',
  'final',
  'is',
  'case',
  'else',
  'finally',
  'static',
  'var',
  'catch',
  'enum',
  'for',
  'new',
  'super',
  'void',
  'class',
  'null',
  'switch',
  'while',
  'const',
  'external',
  'if',
  'this',
  'with',
];

/// Disallowed class names (e.g. they are from dart:core).
const _ILLEGAL_CLASS_NAMES = const [
  'BidirectionalIterator',
  'Comparable',
  'Comparator',
  'DateTime',
  'Deprecated',
  'Duration',
  'Expando',
  'Function',
  'Invocation',
  'Iterable',
  'Iterator',
  'List',
  'Map',
  'Match',
  'Null',
  'Object',
  'Pattern',
  'RegExp',
  'RuneIterator',
  'Runes',
  'Set',
  'StackTrace',
  'Stopwatch',
  'String',
  'StringBuffer',
  'StringSink',
  'Symbol',
  'Type',
  'Uri',
  'AbstractClassInstantiationError',
  'ArgumentError',
  'AssertionError',
  'CastError',
  'ConcurrentModificationError',
  'CyclicInitializationError',
  'Error',
  'Exception',
  'FallThroughError',
  'FormatException',
  'IntegerDivisionByZeroException',
  'NoSuchMethodError',
  'NullThrownError',
  'OutOfMemoryError',
  'RangeError',
  'StackOverflowError',
  'StateError',
  'TypeError',
  'UnimplementedError',
  'UnsupportedError',
];