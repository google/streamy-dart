library example.service;

import 'package:fixnum/fixnum.dart';

class Foo {
  Int64 id;
  String str;
  int number;
}

class Bar {
  Int64 id;
  String xyz;
  List<Foo> foos;
}

class ExampleService {
  
  final String id;
  
  ExampleService._(this.id);
  
  Future<Bar> get(Foo foo);
  Future<Foo> update(Foo a, Bar b, List<int> ids);
}
