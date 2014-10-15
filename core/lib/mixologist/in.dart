part of streamy.mixologist;

class Mixin {
  Map<String, String> imports = <String, String>{};
  String className;
  String baseClass;
  List<String> interfaces = <String>[];
  List<String> classCodeLines = <String>[];
}

const _STATE_IMPORTS = 1;
const _STATE_CLASS = 2;

var rImport = new RegExp('import\\s+[\'"](.*)[\'"](\\s+as\\s+(.*))?\\s*;');

class MixinReader implements StreamConsumer<List<int>> {

  var _future;
  Future addStream(Stream<List<int>> stream) {
    var state = _STATE_IMPORTS;
    _future = stream
      .transform(new Utf8Decoder())
      .transform(new LineSplitter())
      .fold(new Mixin(), (mixin, line) {
        var tline = line.trim();
        if (tline.startsWith('import ')) {
          var m = rImport.matchAsPrefix(line);
          if (m != null) {
            mixin.imports[m[1]] = m[3];
          }
        } else if (tline.startsWith('class')) {
          state = _STATE_CLASS;
          tline = tline.substring(5).trim();
          var i = _indexOf(tline, [' ', '\t', '{']);
          mixin.className = tline.substring(0, i);
          tline = tline.substring(i).trim();
          if (tline.startsWith('extends')) {
            tline = tline.substring(7).trim();
            mixin.baseClass = _parseType(tline);
            tline = tline.substring(mixin.baseClass.length).trim();
          }
          if (tline.startsWith('implements')) {
            tline = tline.substring(10).trim();
            var iface = <String>[];
            var readIfaces = true;
            while (readIfaces) {
              var type = _parseType(tline);
              mixin.interfaces.add(type);
              tline = tline.substring(type.length).trim();
              if (tline.substring(0, 1) == ",") {
                tline = tline.substring(1).trim();
              } else {
                readIfaces = false;
              }
            }
          }
        } else if (state == _STATE_CLASS) {
          mixin.classCodeLines.add(line);
        }
        return mixin;
      });
    return new Future.value();
  }
  
  Future close() => _future;
}

int _indexOf(String s, List<String> ch) {
  var i = -1;
  for (var c in ch) {
    var i2 = s.indexOf(c);
    if (i2 != -1 && (i == -1 || i2 < i)) {
      i = i2;
    }
  }
  return i;
}

String _parseType(String l) {
  var i = _indexOf(l, ["<", ">", ",", " "]);
  var b = l.substring(0, i);
  var r = l.substring(i);
  if (r.substring(0, 1) == "<") {
    b += "<";
    r = r.substring(1);
    while (r.substring(0, 1) == " ") {
      b += " ";
      r = r.substring(1);
    }
    var i = 0;
    while (i++ < 10 && r.substring(0, 1) != ">") {
      var t = _parseType(r);
      b += t;
      r = r.substring(t.length);
      if (r.substring(0, 1) == ",") {
        b += ",";
        r = r.substring(1);
        while (r.substring(0, 1) == " ") {
          b += " ";
          r = r.substring(1);
        }
      }
    }
    b += ">";
  }
  return b;
}
