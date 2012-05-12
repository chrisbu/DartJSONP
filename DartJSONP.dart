#library("DartJSONP");

#import("dart:html");
#import("dart:json");

typedef void OnDataHandler(Map jsonObject);

/// Allow jsonp data access without the fuss by injecting and removing
/// a javascript callback function and a dart postmessage handler function
class JsonpCallback {
  String _callbackFunctionName;
  String get callbackFunctionName() => _callbackFunctionName;
  ScriptElement _script;
  var  _onMessage;

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
  }

  /// Performs JSON request to the [url].
  /// The url must contain the callback function name that was
  /// passed in on the constructor
  //  eg: http://example.com/query?callback=myJsCallback
  doCallback(String url, [OnDataHandler onData]) {
    if (url.contains(this._callbackFunctionName) == false) {
      throw "callback url must contain the callback function name!";
    }

    if (onData != null) {
      this.onDataReceived = onData;
    }


    if (this.onDataReceived == null) {
      throw "onData callback must either be setup in advance, or passed into this method";
    }

    _onMessage = (MessageEvent event) {
      String s = event.data;
      Map json = JSON.parse(s);

      if (json["requestName"] == _callbackFunctionName) {
        //if this is the correct handler, then remove the handler and
        // call teh onDataReceived callback
        window.on.message.remove(_onMessage);
        _removeScriptText();
        Map result = json["jsonpData"];
        //JsonObject jsonObject= new JsonObject.fromMap();
        onDataReceived(result);
      }
    };

    //add the dart onMessage handler
    window.on.message.add(_onMessage);

    //add the correct text back into the JavaScript handler
    _addScriptText();
    document.body.elements.addLast(_script); //add the jsonp callback javascript

    //create the script that will invoke the JSON call
    var script = new Element.tag("script");
    script.src = url;

    // add and remove it is enough
    document.body.elements.addLast(script);
    document.body.elements.removeLast(); //remove the script which initiates the call
  }

  OnDataHandler onDataReceived;
}

