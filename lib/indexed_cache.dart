library streamy.indexed_cache;

import 'dart:async';
import 'dart:convert';
import 'dart:html';
import 'dart:indexed_db' as idb;
import 'package:streamy/streamy.dart';

/// A [Cache] that persists data in IndexedDB.
/// TODO(arick): Some kind of web test for this.
class IndexedDbCache extends Cache {

  final idb.Database db;
  final Duration maxAge;
  var _inGc = false;
  final int gcPerCycleLimit;
  Timer _gcTimer;

  static Future<IndexedDbCache> open({
    Duration gcCycle: const Duration(minutes: 5),
    Duration maxAge: const Duration(days: 7),
    int gcPerCycleLimit: 500
  }) => openNamed("streamy", gcCycle: gcCycle, maxAge: maxAge, gcPerCycleLimit: gcPerCycleLimit);

  static Future<IndexedDbCache> openNamed(name, {
    Duration gcCycle: const Duration(minutes: 5),
    Duration maxAge: const Duration(days: 7),
    int gcPerCycleLimit: 500
  }) {
    return window.indexedDB.open(name, version: 1, onUpgradeNeeded: _initDb).then((database) {
      return new IndexedDbCache._private(database, gcCycle, maxAge, gcPerCycleLimit);
    });
  }

  IndexedDbCache._private(this.db, gcCycle, this.maxAge, this.gcPerCycleLimit) {
    if (gcCycle != null) {
      _gcTimer = new Timer.periodic(gcCycle, (_) => gc());
    }
  }

  static void _initDb(idb.VersionChangeEvent e) {
    idb.Database db = (e.target as idb.Request).result;

    var store = db.createObjectStore("entityCache", keyPath: "request");
    store.createIndex("ts", "ts");
  }

  /// Get an entity from the cache.
  Future<CachedEntity> get(Request key) {
    var jsonKey = key.signature;
    var txn = db.transaction("entityCache", "readonly");
    var store = txn.objectStore("entityCache");
    return store.getObject(jsonKey).then((result) {
      if (result != null && result["entity"] != null) {
        return key.responseDeserializer(result["entity"])
          ..streamy.ts = result["ts"];
      }
      return null;
    });
  }

  /// Set an entity in the cache.
  Future set(Request key, CachedEntity entity) {
    var cacheEntry = {
      "request": key.signature,
      "ts": entity.ts,
      "entity": JSON.encode(entity.entity)
    };
    var txn = db.transaction("entityCache", "readwrite");
    var store = txn.objectStore("entityCache");
    return store.put(cacheEntry);
  }

  /// Invalidate an entity in the cache.
  Future invalidate(Request key) {
    var txn = db.transaction("entityCache", "readwrite");
    var store = txn.objectStore("entityCache");
    return store.delete(key.signature);
  }

  /// Run garbage collection to remove all entries older than the stated date.
  void gc() {
    if (_inGc) {
      return;
    }
    _inGc = true;
    var txn = db.transaction("entityCache", "readwrite");
    var store = txn.objectStore("entityCache");
    var max = new DateTime.now().millisecondsSinceEpoch - maxAge.inMilliseconds;
    List<Future> futures = [];
    store.index("ts").openCursor(range: idb.KeyRange.upperBound_(max), autoAdvance: true)
      .take(gcPerCycleLimit)
      .listen((cursor) {
        futures.add(cursor.delete());
      });
    Future.wait(futures).whenComplete(() {
      _inGc = false;
    });
  }
}
