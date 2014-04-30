part of streamy.generator;

abstract class DartFile {
  final String libraryName;
  final List<DartClass> classes = [];
  
  DartFile(this.libraryName);
  
  void _render(StringBuffer out) {
    if (classes != null && classes.isNotEmpty) {
      classes.forEach((clazz) {
        out.writeln();
        clazz.render(out, 0);
      });
    }
  }
}

class DartLibrary extends DartFile {
  final Map<String, String> imports = {};
  final List<String> parts = [];
  
  DartLibrary(String libraryName) : super(libraryName);
  
  String render() {
    var out = new StringBuffer()
      ..writeln('library $libraryName;');
    if (parts.isNotEmpty) {
      out.writeln();
      parts.forEach((libraryPart) {
        out.writeln("part '${libraryPart.path}';");
      });
    }
    if (imports.isNotEmpty) {
      out.writeln();
      imports.forEach((path, prefix) {
        if (prefix != null) {
          out.writeln("import '$path' as $prefix;");
        } else {
          out.writeln("import '$path';");
        }
      });
    }
    _render(out);
    return out.toString();
  }
}

class DartLibraryPart extends DartFile {
  final String path;
  
  DartLibraryPart(String libraryName, this.path): super(libraryName);
  
  String render() {
    var out = new StringBuffer()
      ..writeln('part of $libraryName;');
    _render(out);
    return out.toString();
  }
}

class DartType {
  final String importNamespace;
  final String dartType;
  final List<DartType> parameters;
  
  const DartType.none() : this('void', null, const []);
  DartType.from(DartClass clazz) : this(clazz.name, null, const []);
  const DartType.dynamic() : this('dynamic', null, const []);
  const DartType.integer() : this('int', null, const []);
  const DartType.boolean() : this('bool', null, const []);
  const DartType.double() : this('double', null, const []);
  const DartType.string() : this('String', null, const []);
  DartType.list(DartType listOf) : this('List', null, [listOf]);
  DartType.stream(DartType streamOf) : this('Stream', null, [streamOf]);
  DartType.map(DartType keyType, DartType valueType) :
      this('Map', null, [keyType, valueType]);
  const DartType(this.dartType, this.importNamespace, this.parameters);
  
  void render(StringBuffer out) {
    if (importNamespace != null) {
      out
        ..write(importNamespace)
        ..write(".");
    }
    out.write(dartType);
    if (parameters.isNotEmpty) {
      out.write("<");
      var first = true;
      parameters.forEach((p) {
        if (!first) {
          out.write(', ');
        }
        first = false;
        p.render(out);
      });
      out.write(">");
    }
  }
  
  String toString() {
    var sb = new StringBuffer();
    render(sb);
    return sb.toString();
  }
}

class DartClass {
  final String name;
  final List<String> comments = [];
  final DartType baseClass;
  final List<DartType> interfaces;
  final List<DartField> fields = [];
  final List<DartMethod> methods = [];
  final List<DartType> mixins = [];
  
  DartClass(this.name, {this.baseClass, this.interfaces});
  
  void render(StringBuffer out, int indent) {
    var id = strings.repeat('  ', indent);
    comments.forEach((line) {
      out
        ..write(id)
        ..write('/// ')
        ..writeln(line);
    });
    out
      ..write(id)
      ..write('class ')
      ..write(name)
      ..write(' ');
    if (baseClass != null) {
      out.write('extends ');
      baseClass.render(out);
      out.write(' ');
    }
    if (interfaces != null && interfaces.isNotEmpty) {
      out.write('implements ');
      var first = true;
      interfaces.forEach((type) {
        if (!first) {
          out.write(', ');
        }
        first = false;
        type.render(out);
      });
      out.write(' ');
    }
    if (mixins.isNotEmpty) {
      out.write('with ');
      var first = true;
      mixins.forEach((mixin) {
        if (!first) {
          out.write(', ');
        }
        first = false;
        mixin.render(out);
      });
      out.write(' ');
    }
    out.writeln('{');
    if (fields != null && fields.isNotEmpty) {
      fields.forEach((field) {
        out.writeln();
        field.render(out, indent + 1);
      });
    }
    if (methods != null && methods.isNotEmpty) {
      methods.forEach((method) {
        out.writeln();
        method.render(out, indent + 1);
      });
    }
    out.writeln('}');
  }
}

class DartMethod {
  final String name;
  final List<String> comments;
  final List<DartParameter> parameters = [];
  final List<DartNamedParameter> namedParameters = [];
  final DartType returnType;
  final DartBody body;

  DartMethod(this.name, this.returnType, this.body);
  
  void render(StringBuffer out, int indent) {
    var id = strings.repeat('  ', indent);
    if (comments != null && comments.isNotEmpty) {
      comments.forEach((line) {
        out
          ..write(id)
          ..write('/// ')
          ..writeln(line);
      });
    }
    out.write(id);
    returnType.render(out);
    out
      ..write(' ')
      ..write(name)
      ..write('(');
    if (parameters.isNotEmpty) {
      var first = true;
      parameters.forEach((p) {
        if (!first) {
          out.write(', ');
        }
        first = false;
        p.render(out);
      });
      if (namedParameters.isNotEmpty) {
        if (!first) {
          out.write(', ');
        }
        out.write('{');
        first = true;
        namedParameters.forEach((p) {
          if (!first) {
            out.write(', ');
          }
          first = false;
          p.render(out);
        });
        out.write('}');
      }
    }
    out.write(') ');
    // One would think this would be indent + 1, but methods provide their own
    // indentation.
    body.render(out, indent);
  }
}

class DartConstructor implements DartMethod {
  final String forClass;
  final String named;
  final List<DartParameter> parameters = [];
  final List<DartNamedParameter> namedParameters = [];
  final DartBody body;
  
  String get name => forClass;
  
  DartConstructor(this.forClass, {this.named, this.body});
  
  void render(StringBuffer out, int indent) {
    var spacing = strings.repeat('  ', indent);
    out
      ..write(spacing)
      ..write(forClass);
    if (named != null) {
      out
        ..write('.')
        ..write(named);
    }
    out.write('(');
    if (parameters.isNotEmpty) {
      var first = true;
      parameters.forEach((p) {
        if (!first) {
          out.write(', ');
        }
        first = false;
        p.render(out);
      });
    }
    if (namedParameters.isNotEmpty) {
      if (!first) {
        out.write(', ');
      }
      out.write('{');
      first = true;
      namedParameters.forEach((p) {
        if (!first) {
          out.write(', ');
        }
        first = false;
        p.render(out);
      });
      out.write('}');
    }
    out.write(')');
    if (body != null) {
      out.write(' ');
      body.render(out, indent);
    } else {
      out.writeln(';');
    }
  }
}

class DartParameter {
  final String name;
  final DartType type;
  final bool isDirectAssignment;
  
  DartParameter(this.name, this.type, {this.isDirectAssignment: false});
      
  void render(StringBuffer out) {
    type.render(out);
    out.write(' ');
    if (isDirectAssignment) {
      out.write('this.');
    }
    out.write(name);
  }
}

class DartNamedParameter extends DartParameter {
  final DartBody defaultValue;  
  
  DartNamedParameter(String name, DartType type, {DartBody this.defaultValue, bool isDirectAssignment: false})
      : super(name, type, isDirectAssignment: isDirectAssignment);
      
  void render(StringBuffer out) {
    super.render(out);
    if (defaultValue != null) {
      out.write(': ');
      // TODO(Alex): Proper indentation.
      defaultValue.render(out, 0, trailingNewline: false);
    }
  }
}

abstract class DartField {
  String get name;
  DartType get type;
  void render(StringBuffer out, int indent);
}

class DartSimpleField implements DartField {
  final String name;
  final DartType type;
  final bool isFinal;
  final bool isStatic;
  final DartBody initializer;
  
  DartSimpleField(this.name, this.type,
      {this.isFinal: false, this.isStatic: false, this.initializer});
  
  void render(StringBuffer out, int indent) {
    out.write(strings.repeat('  ', indent));
    if (isStatic) {
      out.write('static ');
    }
    if (isFinal) {
      out.write('final ');
    }
    if (type != null) {
      type.render(out);
      out.write(' ');
    } else if (!isFinal) {
      out.write('var ');
    }
    out.write(name);
    if (initializer != null) {
      out.write(' = ');
      initializer.render(out, indent, trailingNewline: false);
    }
    out.writeln(';');
  }
}

class DartComplexField implements DartField {
  final String name;
  final DartType type;
  final DartBody getterBody;
  final DartBody setterBody;
  
  DartComplexField(this.name, this.type, this.getterBody, this.setterBody);
  
  DartComplexField.getterOnly(name, type, getterBody) :
      this(name, type, getterBody, null);
  
  void render(StringBuffer out, int indent) {
    out.write(strings.repeat('  ', indent));
    type.render(out);
    out
      ..write(' get ')
      ..write(name)
      ..write(' ');
    getterBody.render(out, indent);
    if (setterBody != null) {
      out
        ..write(strings.repeat('  ', indent))
        ..write('void set ')
        ..write(name)
        ..write('(');
      type.render(out);
      out.write(' value) ');
      setterBody.render(out, indent);
    }
  }
}

abstract class DartBody {
  void render(StringBuffer out, int indent);
}

class DartTemplateBody implements DartBody {
  final mustache.Template template;
  final Map data;
  
  DartTemplateBody(this.template, this.data);
  
  void render(StringBuffer out, int indent, {trailingNewline: true}) {
    var id = strings.repeat('  ', indent);
    var first = true;
    template
      .renderString(data, htmlEscapeValues: false)
      .trim()
      .split('\n')
      .forEach((line) {
        if (!first) {
          out
            ..writeln()
            ..write(id);
        }
        first = false;
        out.write(line);
      });
    if (trailingNewline) {
      out.writeln();
    }
  }
}

class DartConstantBody implements DartBody {
  String body;
  
  DartConstantBody(this.body);
  
  void render(StringBuffer out, int indent, {trailingNewline: true}) {
    var id = strings.repeat('  ', indent);
    var first = true;
    body
      .trim()
      .split('\n')
      .forEach((line) {
        if (!first) {
          out
            ..writeln()
            ..write(id);
        }
        first = false;
        out.write(line);
      });
    if (trailingNewline) {
      out.writeln();
    }
  }
}
