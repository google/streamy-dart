// Provides implementation logic that's shared by both in-browser and
// out-of-browser code.
library streamy.impl;

import 'dart:async';
import 'dart:convert' show JSON;
import 'package:streamy/streamy.dart';

/// A rudimentary [RequestHandler] that serializes [Request] objects to JSON
/// and sends them to the API servers. By default it sends requests to Google
/// API servers, but you can override it by providing your own server address
/// in the contstructor.
class SimpleRequestHandler extends RequestHandler {
  final StreamyHttpService _http;
  final String _apiServerAddress;

  SimpleRequestHandler(this._http,
      {String apiServerAddress}) :
        this._apiServerAddress = apiServerAddress != null
            ? apiServerAddress
            : 'https://content.googleapis.com';

  Stream<Response> handle(HttpRequest request, Trace trace) {
    var cancelCompleter = new Completer();
    var ctrl = new StreamController(
        sync: true,
        onCancel: () {
          cancelCompleter.complete();
        });

    var url = '${_apiServerAddress}/${request.root.servicePath}${request.path}';

    var req = new StreamyHttpRequest(url, request.httpMethod, {
      'Content-Type': 'application/json'
    }, {},
        cancelCompleter.future,
        payload: request.hasPayload ? JSON.encode(request.marshalPayload()) : null);
    _http.send(req).then((StreamyHttpResponse resp) {
      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        var responseJson = jsonParse(resp.body, trace);
        trace.record(new DeserializationStartEvent(resp.body.length));
        var responsePayload = req.unmarshalResponse(responseJson);
        trace.record(new DeserializationEndEvent());
        ctrl.add(new Response(responsePayload, Source.RPC,
            new DateTime.now().millisecondsSinceEpoch));
      } else {
        Map jsonError = null;
        try {
          jsonError = JSON.decode(resp.body);
        } catch(_) {
          // Apparently, body wan't JSON. The caller will have to make do.
        }
        ctrl.addError(new StreamyRpcException(resp.statusCode, request,
            jsonError));
      }
    }, onError: (e) => ctrl.addError(new StreamyRpcException(0, request,
        {'error': {'errors': [{'message': e.message}]}})));

    return ctrl.stream;
  }
}
