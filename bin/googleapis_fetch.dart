/*
 * Downloads all Google APIs from the Google Discovery service and saves them
 * in a specified location.
 *
 * After running this program you can run googleapis_generate.dart to generate
 * Streamy client API packages.
 */
import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:args/args.dart';
import 'package:quiver/strings.dart';
import 'package:quiver/async.dart';

var http = new HttpClient();

Directory outputDir;

main(List<String> args) {
  var errors = [];
  var argp = new ArgParser()
    ..addOption(
        'output-dir',
        abbr: 'o',
        help: 'Directory where downloaded discovery files are to be stored.',
        callback: (v) {
          if (isBlank(v)) {
            errors.add('ERROR: missing option --output-dir');
            return;
          }
          outputDir = new Directory(v);
          outputDir.create(recursive: true);
        });
  argp.parse(args);

  if (!errors.isEmpty) {
    errors.forEach(print);
    print(argp.getUsage());
    exit(1);
  }
  getUrlAsString('https://www.googleapis.com/discovery/v1/apis')
    .then((String discovery) {
      Map json = JSON.decoder.convert(discovery);
      List apis = json['items'];
      var apiNames = new Set();

      Future fetchApi(Map api) {
        String url = api['discoveryRestUrl'];
        String name = api['name'];
        String version = api['version'];

        print('Fetching ${name}:${version} from ${url}');
        apiNames.add(name);

        return getUrlAsString(url).then((d) {
          var discoveryFile =
              new File('${outputDir.path}/${name}_${version}.json');
          discoveryFile.writeAsStringSync(d);
        });
      }

      forEachAsync(apis, fetchApi).then((_) {
        print('------------------------------------');
        print('Fetched ${apis.length} versions of API discovery documents');
        print('From ${apiNames.length} unique APIs.');
      });
    });
}

Future<String> getUrlAsString(String url) =>
    http.getUrl(Uri.parse(url))
      .then((req) => req.close())
      .then(readResponse);

Future<String> readResponse(HttpClientResponse resp) =>
    resp.transform(const Utf8Decoder())
      .fold(new StringBuffer(), (buf, e) => buf..write(e))
      .then((buf) => buf.toString());
