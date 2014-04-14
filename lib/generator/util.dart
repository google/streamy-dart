part of streamy.generator;

String toProperIdentifier(String identifier) => identifier
  .split('_')
  .map((piece) => piece.length > 1 ? (piece.substring(0, 1).toUpperCase() + piece.substring(1)) : piece.toUpperCase())
  .join();
  
List<String> splitStringAcrossLines(String src, [int maxLen = 80]) {
  var lines = [];
  var words = src.split(' ');
  var out = new StringBuffer();
  var outLen = 0;
  words.forEach((word) {
    if (outLen + word.length + 1 <= maxLen) {
      out
        ..write(' ')
        ..write(word);
      outLen += 1 + word.length;
    } else {
      lines.add(out.toString().trim());
      out = new StringBuffer()
        ..write(word);
      outLen = word.length;
    }
  });
  lines.add(out.toString().trim());
  return lines;
}