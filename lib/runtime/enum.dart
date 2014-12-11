part of streamy.runtime;

abstract class Enum {
  
  final String name;
  final int value;
  
  const Enum(this.name, this.value);
  
  String toString() => name;
}
