#import('dart:html');
#import("DartJSONP.dart");

void main() {
  final gplusApiKey = "AIzaSyDQkKqW-XrUakARo-96vHh1oBbWv50udL4";

  JsonpCallback gplusCallback = new JsonpCallback("gplusFunction");
  gplusCallback.onDataReceived = _onGPlusDataReceived;


  JsonpCallback twitterCallback = new JsonpCallback("twitterFunction");
  twitterCallback.onDataReceived = _onTwitterDataReceived;


  document.body.query("#searchButton").on.click.add((event) {
    var searchText = getSearchText();

    var gplusUrl = "https://www.googleapis.com/plus/v1/activities?query=$searchText&pp=1&key=$gplusApiKey&callback=${gplusCallback.callbackFunctionName}";
    gplusCallback.doCallback(gplusUrl);

    var twitterUrl = "http://search.twitter.com/search.json?q=$searchText&callback=${twitterCallback.callbackFunctionName}";
    twitterCallback.doCallback(twitterUrl);
  });

}


getSearchText() {
  var searchText = document.query("#searchText").value;
  print(searchText);
  if (searchText.startsWith("#")) {
    searchText = "%23" + searchText.substring(1);
  }

  return searchText;
}


_onTwitterDataReceived(Map data) {
  //add data to the UI
  document.body.query("#twitter").nodes.clear();
  document.body.query("#twitter").nodes.add(new Element.html("<p>Twitter</p>"));

  for (var i = 0; i < data["results"].length; i++) {
    var title = data["results"][i]["text"];
    var postedBy = data["results"][i]["from_user_name"];
    var twitterUrl = "http://www.twitter.com/#!/${data['results'][i]['from_user']}";
    var image =  data["results"][i]["profile_image_url"];

    var element = buildUiElement("",postedBy,twitterUrl,image,title);
    //var element = new Element.html("<div class='result'><a href='$twitterUrl' target='_blank'>$title</a> by $postedBy<br/></div>");
    document.body.query("#twitter").nodes.add(element);
  }
}

_onGPlusDataReceived(Map data) {
  //add data to the UI
  document.body.query("#gplus").nodes.clear();
  document.body.query("#gplus").nodes.add(new Element.html("<p>Google Plus</p>"));

  for (var i = 0; i < data["items"].length; i++) {
    var title = data["items"][i]["title"];
    var content = data["items"][i]["object"]["content"];
    var postedBy = data["items"][i]["actor"]["displayName"];
    var gplusUrl = data["items"][i]["url"];
    var image = data["items"][i]["actor"]["image"]["url"];

    var element = buildUiElement(title,postedBy,gplusUrl,image,content);
    //var element = new Element.html("<div class='result'><a href='$gplusUrl' target='_blank'>$title</a> by $postedBy<br/>$content<br/></div>");
    document.body.query("#gplus").nodes.add(element);
  }
}


Element buildUiElement(String title, String user, String url, String image, [String content]) {
  if (content == null) {
    content = "";
  }

   var element = new Element.html("""
 <div class='result'><img src='$image'><span class='itemtitle'>$title</span><br/><span class='user'> by <a href='$url' target='_blank'>$user</a></span><br/><br/>$content</div>
""");

   return element;
}