import "package:streamy/base.dart";
import "package:unittest/unittest.dart";

main() {
  group(".local", () {
    var entity;
    setUp(() {
      entity = new RawEntity();
    });
    test("exists and looks like a Map", () {
      expect(entity.local, isNotNull);
      expect(entity.local, new isInstanceOf<Map>());
    });
    test("stores and retrieves data via operator[]", () {
      entity.local['foo'] = 'bar';
      expect(entity.local['foo'], equals('bar'));
    });
    test("has dot property access", () {
      entity.local['foo'] = 'bar';
      expect(entity.local.foo, equals('bar'));
      entity.local.foo = 'baz';
      expect(entity.local['foo'], equals('baz'));
    });
    test("converts Maps to LocalDataMaps", () {
      entity.local.foo = {'bar': true};
      expect(entity.local.foo, new isInstanceOf<LocalDataMap>());
    });
    test("does not affect serialization of the entity", () {
      var s1 = entity.toJson();
      entity.local.foo = 'not serialized';
      var s2 = entity.toJson();
      expect(s2, equals(s1));
    });
    test("has equality semantics", () {
      var entity2 = new RawEntity();
      entity.local.foo = 'bar';
      entity2.local.foo = 'bar';
      expect(entity.local == entity2.local, isTrue);
      entity2.local.foo = 'baz';
      expect(entity.local == entity2.local, isFalse);
    });
    test("does not survive cloning", () {
      entity.local.foo = 'this should not be cloned';
      expect(entity.clone().local.foo, isNull);
    });
  });
}
