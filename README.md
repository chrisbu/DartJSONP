**DartJSONP**

(Created at the London Dart hackathon)

Inspired by Seth's blog post which explained how to use JSONP and postmessage with Dart:
http://blog.sethladd.com/2012/03/jsonp-with-dart.


Allow easy JSONP data access without the fuss by injecting and removing
a javascript callback function and a dart postmessage handler function

For example:

    var callbackFuncName = "twitterFunction";
    JsonpCallback twitterCallback = new JsonpCallback(callbackFuncName);
    twitterCallback.onDataReceived = (Map data) {
      // do something with the returned data
    };
    
    var twitterUrl = "http://search.twitter.com/search.json?q=dartlang&callback=$callbackFuncName";
    twitterCallback.doCallback(twitterUrl);
    
    
You can see this running here:  http://example.dartwatch.com/jsonp/DartJsonPtest.html

Internally, it adds the javascript, performs the request and when
the callback is received by javascript and forwarded back to dart, it removes the 
scripts (as best it can), to clean up after itself.