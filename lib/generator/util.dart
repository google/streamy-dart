library streamy.generator.utilities;

import 'package:streamy/generator/ir.dart';

/// Filters a map of [properties] leaving only properties of [base] type or
/// hierarchies of lists of element of [base] type.
Map<String, Field> fieldsOf(String base, Map<String, Field> properties) =>
    _toMap(_entries(properties)
        .where((_MapEntry<String, Field> e) => _hierarchyOf(base, e.value.typeRef))
        .map((f) => f.name));

/// Returns true iff either the [type] is of given [base] type or the [type] is
/// a hierarchy of lists of elements of [base] type. For example:
///
///     _hierarchyOf('int64', new TypeRef.int64()); // true
///     _hierarchyOf('int64', new TypeRef.string()); // false
///     _hierarchyOf('int64', new TypeRef.list(new TypeRef.int64())); // true
///     _hierarchyOf('int64', new TypeRef.list(new TypeRef.string())); // true
bool _hierarchyOf(String base, TypeRef type) {
  if (type.base == base) {
    return true;
  } else if (type is ListTypeRef) {
    return _hierarchyOf(base, type.subType);
  }
  return false;
}

// TODO(yjbanov): should _entries, _toMap and _MapEntry be in quiver?
Iterable<_MapEntry> _entries(Map map) =>
  map.keys.map((k) => new _MapEntry(k, map[k]));

Map _toMap(Iterable<_MapEntry> entries) =>
    new Map.fromIterable(entries, key: (e) => e.key, value: (e) => e.value);

class _MapEntry<K, V> {
  final K key;
  final V value;
  _MapEntry(this.key, this.value);
}

String joinParts(Iterable<String> parts) {
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

String makePropertyName(String name) {
  name = _fixIllegalChars(name);
  if (_ILLEGAL_PROPERTY_NAMES.contains(name)) {
    name = '\$${name}';
  }
  return name;
}

String makeMethodName(String name) {
  name = _fixIllegalChars(name);
  if (_ILLEGAL_METHOD_NAMES.contains(name)) {
    name = '\$${name}';
  }
  return name;
}

String makeRemoverName(String name) {
  name = _capitalize(_fixIllegalChars(name));
  return 'remove${name}';
}

String makeHandlerName(String name) {
  name = _capitalize(_fixIllegalChars(name));
  return '_handle${name}';
}

String makeClassName(String name) {
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