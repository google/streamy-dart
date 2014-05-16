library streamy.trait.dot_access;

class DotAccess {
  
  _resolve(List<String> pieces, start) {
    var cur = start;
    for (var i = 0; i < pieces.length; i++) {
      cur = cur[pieces[i]];
      if (cur == null) {
        return null;
      }
    }
    return cur;
  }
  
  bool containsKey(String key) {
    if (!key.contains('.')) {
      return super.containsKey(key);
    }
    var pieces = key.split('.');
    var last = pieces.removeLast();
    var target = _resolve(pieces, this);
    if (target == null) {
      return false;
    }
    return target.containsKey(last);
  }

  operator[](String key) {
    if (!key.contains('.')) {
      return super[key];
    }
    var pieces = key.split('.');
    var last = pieces.removeLast();
    var target = _resolve(pieces, this);
    if (target == null) {
      return null;
    }
    return target[last];
  }

  operator[]=(String key, value) {
    if (!key.contains('.')) {
      super[key] = value;
      return;
    }
    var pieces = key.split('.');
    var last = pieces.removeLast();
    var target = _resolve(pieces, this);
    target[last] = value;
  }
  
  remove(String key) {
    if (!key.contains('.')) {
      return super.remove(key);
    }
    var pieces = key.split('.');
    var last = pieces.removeLast();
    var target = _resolve(pieces, this);
    return target.remove(last);
  }
}
