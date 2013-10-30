part of streamy.runtime;

class Response<T> {
  final T entity;
  final String source;
  final int ts;
  
  const Response(this.entity, this.source, this.ts);
}

abstract class Source {
  static const RPC = 'RPC';
  static const CACHE = 'CACHE';
  static const ERROR = 'ERROR';
}
