library streamy.test.generated.service.interface;

class Foo {
  int id;
  String name;
}

class Bar {
  int id;
  Foo foo;
}

class Service {
  Future<Bar> barFor(Foo foo);
}