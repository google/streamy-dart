part of streamy.generator;

String toProperIdentifier(String identifier, {firstLetter: true}) {
  var first = !firstLetter;
  var name = identifier
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
  if (name.length == 0) {
    throw new StateError('Empty property, schema, resource or method name');
  }

  // Replace bad starting character with dollar sign (it has to be public)
  if (!name.startsWith(IDENTIFIER_START)) {
    name = '\$${name.substring(1)}';
  }
  // Replace bad characters in the middle with underscore
  name = name.replaceAll(NON_IDENTIFIER_CHAR_MATCHER, '_');
  if (name.startsWith('_')) {
    name = 'clean${name}';
  }
  return name;
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