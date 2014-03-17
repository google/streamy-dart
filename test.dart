library test;

main() {
  new Bar().method();
}

class Foo {
  
  method() => print("Test");
}

class Bar extends Foo {
  noSuchMethod(Invocation inv) {
    print("Invoking ${inv.memberName}");
  }
}