library streamy.impl;

import 'dart:async';
import 'dart:convert';
import 'package:streamy/streamy.dart';

class SimpleRequestHandler extends RequestHandler {
  final StreamyHttpService _http;

  SimpleRequestHandler(this._http);

  Stream<Response> handle(Request request, Trace trace) {
    var cancelCompleter = new Completer();
    var ctrl = new StreamController(
        sync: true,
        onCancel: () {
          cancelCompleter.complete();
        });

    var url = 'https://content.googleapis.com/${request.root.servicePath}${request.path}';

    var req = new StreamyHttpRequest(url, request.httpMethod, {
      'Content-Type': 'application/json'
    }, {},
        cancelCompleter.future,
        payload: request.payload != null ?
            JSON.encode(request.payload.toJson()) : null);
    _http.send(req).then((StreamyHttpResponse resp) {
      ctrl.add(new Response(
          request.responseDeserializer(resp.body, trace),
          'RPC',
          new DateTime.now().millisecondsSinceEpoch));
    }, onError: ctrl.addError);
    return ctrl.stream;
  }
}
