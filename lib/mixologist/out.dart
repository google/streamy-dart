part of streamy.mixologist;

class LinearizedTarget {
  final String finalClassName;
  final String intermediatePrefix;
  final String baseClassName;
  
  final List<Mixin> mixins;
  
  LinearizedTarget(this.finalClassName, this.intermediatePrefix, this.baseClassName, this.mixins);
  
  List<String> linearize() {
    var baseClass = baseClassName != null ? baseClassName : "Object";
    var out = <String>[];
    
    // Output each mixin.
    mixins.forEach((mixin) {
      var className = "$intermediatePrefix${mixin.className}";
      var classDef = "abstract class $className extends $baseClass";
      if (mixin.interfaces.isNotEmpty) {
        classDef += ' implements ' + mixin.interfaces.join(', ');
      }
      classDef += ' {';
      out.add(classDef);
      out.addAll(mixin.classCodeLines);
      out.add('');
      baseClass = className;
    });
    
    // Output the final class.
    out.add("class $finalClassName extends $baseClass {}");
    return out;
  }
}