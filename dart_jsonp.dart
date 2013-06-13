library dart_jsonp;

import 'dart:html';
import 'dart:json';
import 'dart:async';

typedef void OnDataHandler(Map jsonObject);

/// Allow jsonp data access without the fuss by injecting and removing
/// a javascript callback function and a dart postmessage handler function
class JsonpCallback {
  String _callbackFunctionName;
  String get callbackFunctionName => _callbackFunctionName;
  ScriptElement _script;
  var  _onMessage;
  var _onMessageSub;

  /// constructor - the [_callbackFunctionName] is mandatory.
  /// This is the name that you will provide to your json request url
  /// and it will be injected into the dom as a javscript callback function
  /// once the callback is received, the function will be removed.
  ///
  /// IMPORTANT:  Make sure that you don't have two callback functions
  /// with the same name.
  JsonpCallback(String this._callbackFunctionName) {
    _script = new Element.tag("script");

  }

  /// add the callback script and wrap it in the callback function name
  /// so that we can identify it when dart receives the postmessage.
  /// We want to make sure that the postMessage is for the correct
  /// call
  _addScriptText() {
    _script.text = """
        function $_callbackFunctionName(s) { 
          var messageData = JSON.stringify(s);
          var data = '{"requestName":"$_callbackFunctionName","jsonpData":' + messageData + '}';           
          window.postMessage(data, '*');
        }
    """;
  }

  /// set the script to be empty, as we can't actually remove tags
  /// from the dom yet
  _removeScriptText() {
    _script.text = "";
    _script.remove();
  }

  /// Performs JSON request to the [url].
  /// The url must contain the callback function name that was
  /// passed in on the constructor
  //  eg: http://example.com/query?callback=myJsCallback
  Future<Map> doCallback(String url, [OnDataHandler onData]) {
    if (url.contains(this._callbackFunctionName) == false) {
      throw "callback url must contain the callback function name!";
    }

    if (onData != null) {
      this.onDataReceived = onData;
    }

    var completer = new Completer<Map>();

    _onMessage = (MessageEvent event) {
      String s = event.data;
      Map json = parse(s);

      if (json["requestName"] == _callbackFunctionName) {
        // if this is the correct handler, then remove the handler and
        // call the onDataReceived callback and return a future
        _onMessageSub.cancel();
        _removeScriptText();
        Map result = json["jsonpData"];

        // if we have a callback handler, then use it
        if (onDataReceived != null) {
         onDataReceived(result);
        }

        // also return a future
        completer.complete(result);
      }
    };

    //add the dart onMessage handler
    _onMessageSub = window.onMessage.listen(_onMessage);

    //add the correct text back into the JavaScript handler
    _addScriptText();
    document.body.nodes.add(_script); //add the jsonp callback javascript

    //create the script that will invoke the JSON call
    ScriptElement script = new Element.tag("script");
    script.src = url;

    // add and remove it is enough
    document.body.nodes.add(script);
    document.body.nodes.removeLast(); //remove the script which initiates the call

    return completer.future;
  }

  OnDataHandler onDataReceived;
  
}
