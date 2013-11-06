part of streamy.runtime;

class Response<T> {
  final T entity;
  final String source;
  final String authority;
  final int ts;

  const Response(this.entity, this.source, this.ts, {this.authority: Authority.PRIMARY});
}

abstract class Source {
  static const RPC = 'RPC';
  static const CACHE = 'CACHE';
  static const ERROR = 'ERROR';
}

abstract class Authority {
  static const PRIMARY = 'PRIMARY';
  static const SECONDARY = 'SECONDARY';
}