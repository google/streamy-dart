library streamy.runtime.entity.wrapper.test;

import 'dart:async';
import 'package:streamy/streamy.dart';
import 'package:streamy/collections.dart';
import 'package:streamy/testing/testing.dart';
import 'package:unittest/unittest.dart';

class TestWrappedEntity extends EntityWrapper {
  TestWrappedEntity(Map data) : super.wrap(
      new DynamicEntity.fromMap(data), (entity) => throw "Not supported");
  Type get streamyType => throw "Not supported";
}

main() {
  group('EntityWrapper', () {
    test('should return field names as Iterable and not crash', () {
      var subject = new TestWrappedEntity({
        "a": 1,
        "b": "z",
      });
      var fields = new ComparableList.from(subject.fieldNames);
      var expectedFields = new ComparableList.from(["a", "b"]);
      expect(fields, equals(expectedFields));
    });
  });
}
