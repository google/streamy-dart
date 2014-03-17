part of streamy.runtime;

/// Public interface of Streamy entities.
abstract class Entity {

  /// Check for deep equality of entities (slow).
  /// TODO(arick): figure out a way to clean this up a bit.
  static bool deepEquals(Entity first, Entity second) {
    if (identical(first, second)) {
      return true;
    }
    if (first == null || second == null) {
      return (first == second);
    }

    if (first.local.length != second.local.length) {
      return false;
    }

    // Loop through each field, checking equality of the values.
    var fieldNames = first.keys.toList(growable: false);
    var len = fieldNames.length;
    if (len != second.keys.length) {
      return false;
    }
    for (var i = 0; i < len; i++) {
      if (!second.containsKey(fieldNames[i])) {
        return false;
      }
      var firstValue = first[fieldNames[i]];
      var secondValue = second[fieldNames[i]];
      if (firstValue is Entity && secondValue is Entity) {
        if (!Entity.deepEquals(firstValue, secondValue)) {
          return false;
        }
      } else if (firstValue is List && secondValue is List) {
        if (firstValue.length != secondValue.length) {
          return false;
        }
        for (var j = 0; j < firstValue.length; j++) {
          if (firstValue[j] is Entity && secondValue[j] is Entity) {
            if (!Entity.deepEquals(firstValue[j], secondValue[j])) {
              return false;
            }
          } else if (firstValue[j] != secondValue[j]) {
            return false;
          }
        }
      } else if (firstValue != secondValue) {
        return false;
      }
    }
    return true;
  }

  /// Compute the deep hash code of an entity (slow).
  static int deepHashCode(Entity entity) {
    // Running total, kept under MAX_HASHCODE.
    var running = 0;
    var fieldNames = new List.from(entity.keys)..sort();
    var len = fieldNames.length;
    for (var i = 0; i < len; i++) {
      running = ((17 * running) + fieldNames[i].hashCode) % MAX_HASHCODE;
      var value = entity[fieldNames[i]];
      if (value is Entity) {
        running = ((17 * running) + Entity.deepHashCode(value)) % MAX_HASHCODE;
      } else if (value is List) {
        for (var listValue in value) {
          if (listValue is Entity) {
            running = ((17 * running) + Entity.deepHashCode(listValue)) % MAX_HASHCODE;
          } else {
            running = ((17 * running) + listValue.hashCode) % MAX_HASHCODE;
          }
        }
      } else {
        running = ((17 * running) + value.hashCode) % MAX_HASHCODE;
      }
    }
    return running;
  }
}
