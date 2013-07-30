library streamy.indexed_cache;

import 'dart:async';
import 'dart:html';
import 'dart:indexed_db' as idb;
import 'dart:json' as json;
import 'package:streamy/streamy.dart';

class IndexedDbCache extends Cache {
  
  final String name;
  Future<idb.Database> _database;
  final Duration maxAge;
  var _inGc = false;
  final int gcPerCycleLimit;
  Timer _gcTimer;
  
  IndexedDbCache({
    Duration gcCycle: const Duration(minutes: 5),
    Duration maxAge: const Duration(days: 7),
    int gcPerCycleLimit: 500
  }) : this.named("streamy", gcCycle: gcCycle, maxAge: maxAge, gcPerCycleLimit: gcPerCycleLimit);

  IndexedDbCache.named(this.name, {
    Duration gcCycle: const Duration(minutes: 5),
    this.maxAge: const Duration(days: 7),
    this.gcPerCycleLimit: 500
  }) {
    _database = window.indexedDB.open(name, version: 1, onUpgradeNeeded: _initDb);
    if (gcCycle != null) {
      _gcTimer = new Timer.periodic(gcCycle, (_) => gc());
    }
  }
  
  void _initDb(idb.VersionChangeEvent e) {
    idb.Database db = (e.target as idb.Request).result;
    
    var store = db.createObjectStore("entityCache", keyPath: "request");
    store.createIndex("ts", "ts");
  }

  /// Get an entity from the cache.
  Future<Entity> get(Request key) {
    var jsonKey = key.signature;
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
      "request": key.signature,
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
      return store.delete(key.signature);
    });
  }

  /// Run garbage collection to remove all entries older than the stated date.
  Future gc() {
    if (_inGc) {
      return;
    }
    _inGc = true;
    return _database.then((db) {
      var txn = db.transaction("entityCache", "readwrite");
      var store = txn.objectStore("entityCache");
      var max = new DateTime.now().millisecondsSinceEpoch - maxAge.inMilliseconds;
      List<Future> futures = [];
      store.index("ts").openCursor(range: idb.KeyRange.upperBound_(max), autoAdvance: true)
        .take(gcPerCycleLimit)
        .listen((cursor) {
          futures.add(cursor.delete());
        });
      return Future.wait(futures);
    }).whenComplete(() {
      _inGc = false;
    });
  }
}
