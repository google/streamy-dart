import "package:streamy/base.dart";
import "package:unittest/unittest.dart";

main() {
  group("Entity", () {
    test("factory constructor returns a DynamicEntity", () {
      expect(new Entity(), new isInstanceOf<DynamicEntity>());
    });
    test("factory constructor fromMap returns a DynamicEntity", () {
      var e = new Entity.fromMap({"foo": "bar"});
      expect(e, new isInstanceOf<DynamicEntity>());
      expect(e.foo, equals("bar"));
    });
  });
}
