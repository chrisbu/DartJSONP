**DartJSONP**

(Created at the London Dart hackathon)


Allow easy JSONP data access without the fuss by injecting and removing
a javascript callback function and a dart postmessage handler function

For example:

    var callbackFuncName = "twitterFunction";
    JsonpCallback twitterCallback = new JsonpCallback(callbackFuncName);
    twitterCallback.onDataReceived = (Map data) {
      // do something with the returned data
    };
    
    var twitterUrl = "http://search.twitter.com/search.json?q=dartlang&callback=" + callbackFuncName;
    twitterCallback.doCallback(twitterUrl);