library streamy.indexed_cache;

import 'dart:html';
import 'dart:indexed_db';
import 'package:streamy/streamy.dart';

class IndexedDbCache extends Cache {
  
  final String name;
  Future<Database> _database;
  
  IndexedDbCache() : this.named("streamy.cache");
  
  IndexedDbCache.named(this.name) {
    _database = window.indexedDB.open(name, version: 1, onUpgradeNeeded: _initDb)
  }
  
  void _initDb(VersionChangeEvent e) {
    Database db = (e.target as Request).result;
    
    var store = db.createObjectStore("streamy.cache", autoIncrement: true);
    store.createIndex('request-index', 'request', {unique: true});
    store.createIndex('ts-index', 'ts');
  }

  /// Get an entity from the cache.
  Future<Entity> get(Request key);

  /// Set an entity in the cache.
  Future set(Request key, Entity entity);

  /// Invalidate an entity in the cache.
  Future invalidate(Request key);
}
