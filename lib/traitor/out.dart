part of streamy.traitor;

class LinearizedTarget {
  final String finalClassName;
  final String intermediatePrefix;
  final String baseClassName;
  
  final List<Trait> traits;
  
  LinearizedTarget(this.finalClassName, this.intermediatePrefix, this.baseClassName, this.traits);
  
  List<String> linearize() {
    var baseClass = baseClassName != null ? baseClassName : "Object";
    var out = <String>[];
    
    // Output each trait.
    traits.forEach((trait) {
      var className = "$intermediatePrefix${trait.className}";
      var classDef = "abstract class $className extends $baseClass";
      if (trait.interfaces.isNotEmpty) {
        classDef += ' implements ' + trait.interfaces.join(', ');
      }
      classDef += ' {';
      out.add(classDef);
      out.addAll(trait.classCodeLines);
      out.add('');
      baseClass = className;
    });
    
    // Output the final class.
    out.add("class $finalClassName extends $baseClass {}");
    return out;
  }
}