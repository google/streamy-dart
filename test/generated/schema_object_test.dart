import "dart:json";
import "package:third_party/dart/unittest/lib/unittest.dart";
import "package:third_party/dart/streamy/lib/comparable.dart";
import "package:third_party/dart/streamy/test/generated/schema_object_client.dart";

main() {
  group("SchemaObjectTest", () {
    Foo foo;
    setUp(() {
      foo = new Foo()
      ..id = 1
      ..bar = "bar"
      ..baz = 2
      ..qux = 1.5;
    });
    test("DataCorrectlyPopulated", () {
      expect(foo.id, equals(1));
      expect(foo.bar, equals("bar"));
      expect(foo.baz, equals(2));
      expect(foo.qux, equals(1.5));
    });
    test("DataMapCorrectlyPopulated", () {
      expect(foo["id"], equals(1));
      expect(foo["bar"], equals("bar"));
      expect(foo["baz"], equals(2));
      expect(foo["qux"], equals(1.5));
    });
    test("JsonCorrectlyPopulated", () {
      expect(foo.toJson(), equals({
        "id": 1,
        "bar": "bar",
        "baz": 2,
        "qux": "1.5",
      }));
    });
    test("RemovedKeyNotPresentInJson", () {
      expect(foo.removeBaz(), equals(2));
      expect(foo.toJson(), equals({
        "id": 1,
        "bar": "bar",
        "qux": "1.5",
      }));
    });
    test("RemovedKeyGetsNull", () {
      foo.removeBaz();
      expect(foo.baz, isNull);
    });
    test("SerializeListToJson", () {
      var bar = new Bar()..foos = [new Foo()..id = 321];
      bar = new Bar.fromJsonString(stringify(bar.toJson()));
      expect(bar.foos.length, equals(1));
      expect(bar.foos[0].id, equals(321));
    });
    test("DeserializeMissingListToNull", () {
      var bar = new Bar.fromJsonString("{}");
      expect(bar.foos, isNull);
    });
    test("List of int64s works properly", () {
      foo.quux = [1, 2, 3, 4];
      expect(foo.quux, equals([1, 2, 3, 4]));
      expect(foo["quux"], equals([1, 2, 3, 4]));
      expect(foo.toJson()["quux"], equals(["1", "2", "3", "4"]));
    });
    test("Deserialize formatted strings and lists", () {
      var foo2 = new Foo.fromJson({
        "qux": "2.5",
        "quux": ["2", "3", "4", "5"]
      });
      expect(foo2.qux, equals(2.5));
      expect(foo2.quux, equals([2, 3, 4, 5]));
    });
    test("Lists get turned into ComparableLists", () {
      var bar = new Bar()
        ..foos = [foo];
      expect(bar.foos, new isInstanceOf<ComparableList>());
      bar["direct"] = [foo];
      expect(bar["direct"], new isInstanceOf<ComparableList>());
    });
    test("clone()'d entities are equal", () {
      expect(foo.clone(), equals(foo));
      var bar = new Bar()
        ..foos = [foo];
      expect(bar.clone(), equals(bar));
    });
    test("clone() is deep", () {
      var bar = new Bar()
        ..foos = [foo];
      var bar2 = bar.clone();

      // bar2 should be a Bar too.
      expect(bar2, new isInstanceOf<Bar>());
      // They shouldn't be identical.
      expect(bar2, isNot(same(bar)));
      // And the Foos inside them should not be identical (deep clone).
      expect(bar2.foos[0], isNot(same(bar.foos[0])));

      // This tests that the [EntityWrapper] subclasses aren't identical, but
      // not the [RawEntity] entities inside them.
      bar.foos[0].baz = 42;
      expect(bar, isNot(equals(bar2)));
    });
  });
}
