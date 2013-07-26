library streamy.indexed_cache;

import 'dart:async';
import 'dart:html';
import 'dart:indexed_db' as idb;
import 'dart:json' as json;
import 'package:streamy/streamy.dart';

class IndexedDbCache extends Cache {
  
  final String name;
  Future<idb.Database> _database;
  var _maxAgeInMillis = 5000;
  var _inGc = false;
  Timer _gcTimer;
  
  IndexedDbCache() : this.named("streamy");
  
  IndexedDbCache.named(this.name) {
    _database = window.indexedDB.open(name, version: 1, onUpgradeNeeded: _initDb);
    _gcTimer = new Timer.periodic(new Duration(seconds: 5), (_) => gc());
  }
  
  void _initDb(idb.VersionChangeEvent e) {
    idb.Database db = (e.target as idb.Request).result;
    
    var store = db.createObjectStore("entityCache", keyPath: "request");
    store.createIndex("ts", "ts");
  }

  /// Get an entity from the cache.
  Future<Entity> get(Request key) {
    var jsonKey = json.stringify(key);
    return _database.then((db) {
      var txn = db.transaction("entityCache", "readonly");
      var store = txn.objectStore("entityCache");
      return store.getObject(jsonKey);
    }).then((result) {
      if (result != null && result["entity"] != null) {
        return key.responseDeserializer(result["entity"])
          ..streamy.ts = result["ts"];
      }
      return null;
    });
  }

  /// Set an entity in the cache.
  Future set(Request key, Entity entity) {
    var cacheEntry = {
      "request": json.stringify(key),
      "ts": entity.streamy.ts,
      "entity": json.stringify(entity)
    };
    return _database.then((db) {
      var txn = db.transaction("entityCache", "readwrite");
      var store = txn.objectStore("entityCache");
      return store.put(cacheEntry);
    });
  }

  /// Invalidate an entity in the cache.
  Future invalidate(Request key) {
    return _database.then((db) {
      var txn = db.transaction("entityCache");
      var store = txn.objectStore("entityCache");
      return store.delete(key);
    });
  }
  
  Future gc() {
    if (_inGc) {
      print("Already in gc.");
      return;
    }
    print("gc start");
    _inGc = true;
    return _database.then((db) {
      var txn = db.transaction("entityCache", "readwrite");
      var store = txn.objectStore("entityCache");
      var max = new DateTime.now().millisecondsSinceEpoch - _maxAgeInMillis;
      List<Future> futures = [];
      store.index("ts").openCursor(keyRange: new idb.KeyRange.upperBound_(max), autoAdvance: true).listen((cursor) {
        print("Invalidating: $key");
        futures.add(store.delete(cursor.key));
      });
      return Future.wait(futures);
    }).whenComplete(() {
      _inGc = false;
    });
  }
}
