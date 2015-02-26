part of streamy.runtime;

typedef T LazyDeserializerFn<T>(rawValue);

/// A [Lazy] represents a value of type T with a high cost of deserialization.
class Lazy<T> {
  
  var rawValue;
  LazyDeserializerFn<T> deserializer;

  /// Construct a lazily deserialized value from a raw value and a closure
  /// to deserialize it.
  Lazy(this.rawValue, this.deserializer);
  
  T resolve() => deserializer(rawValue);
  
  static toLazy(LazyDeserializerFn deserializer) =>
      ((v) => new Lazy(v, deserializer));
}

// An [ObservableList] that understands [Lazy] values and silently resolves them.
class LazyList<E> extends ListBase<E> implements ObservableList<E> {
  
  // Not ObservableList<E> since this can contain Lazy elements which aren't of
  // type E.
  ObservableList delegate;
  bool _changesDisabled = false;
  StreamController<List<ChangeRecord>> _changes;
  
  LazyList(this.delegate);
  
  int get length => delegate.length;
  void set length(int newLength) => delegate.length = newLength;
  
  E operator[](int index) {
    var value = delegate[index];
    if (value is Lazy) {
      value = value.resolve();
      
      // Fire any batched changes before disabling them to update the value.
      deliverChanges();
      _changesDisabled = true;
      
      // Replace the resolved value in the list.
      delegate[index] = value;
      
      // Make sure the replacement change has been discarded before enabling
      // changes again.
      deliverChanges();
      _changesDisabled = false;
    }
    
    return value;
  }
  
  void operator[]=(int index, E value) {
    delegate[index] = value;
  }
  
  // Manually delegating [add] and [addAll] as per [ListBase] performance
  // recommendations.
  void add(E value) => delegate.add(value);
  void addAll(Iterable<E> iterable) => delegate.addAll(iterable);
  
  // Observable interface.
  bool deliverChanges() => delegate.deliverChanges();
  bool deliverListChanges() => delegate.deliverListChanges();
  void discardListChages() => delegate.discardListChages();
  void discardListChanges() => delegate.discardListChages();
  
  void notifyChange(ChangeRecord record) => delegate.notifyChange(record);
  notifyPropertyChange(Symbol field, Object oldValue, Object newValue) =>
      delegate.notifyPropertyChange(oldValue, newValue);
  void observed() => delegate.observed();
  void unobserved() => delegate.unobserved();
  
  Stream<List<ChangeRecord>> get changes {
    if (_changes == null) {
      var sub;
      _changes = new StreamController<List<ChangeRecord>>.broadcast(onListen: () {
        sub = delegate.changes.listen((changeList) {
          if (!_changesDisabled) {
            _changes.add(changeList);
          }
        });
      }, onCancel: () => sub.cancel());
    }
    return _changes.stream;
  }
}
