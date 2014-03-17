library streamy.trait.immutable;

class Immutability {
  
  bool _isFrozen = false;
  
  operator[]=(String key, value) {
    if (_isFrozen) {
      throw new Exception("Frozen.");
    }
    super[key] = value;
  }
  
  remove(String key) {
    if (_isFrozen) {
      throw new Exception("Frozen.");
    }
    return super.remove(key);
  }
  
  void freeze() {
    _isFrozen = true;
  }
  
  bool get isFrozen => _isFrozen;
}
