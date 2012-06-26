jQuery(document).ready(function ($) {
  $.getScript('//platform.twitter.com/widgets.js', function () {
    var twitterCallbacks = {

      extractURL:function(target){
        if (target && target.nodeName == 'A') {
          return twitterCallbacks.extractParamFromUri(target.href, 'url');
        } else {
          return null;
        }
      },

      // take the twitter intent link and extract the share URL from the parameters being passed to that URL.
      // really twitter, you could not have just put this in the intent hash?
      extractParamFromUri:function(uri, paramName) {
        if (!uri) {
          return;
        }
        var regex = new RegExp('[\\?&#]' + paramName + '=([^&#]*)');
        var params = regex.exec(uri);
        if (params != null) {
          return decodeURI(params[1]);
        }
        return;
      },

      pushToGaq:function(intent_event){
        if (!_gaq) {
          return;
        }
        _gaq.push(['_trackEvent', 'twitter', intent_event.type, twitterCallbacks.extractURL(intent_event.target)]);
      },

      // Define our custom event hanlders
      clickEventToAnalytics:function (intent_event) {
        if (intent_event) {
          twitterCallbacks.pushToGaq(intent_event);
        }
      },

      tweetIntentToAnalytics:function (intent_event) {
        if (intent_event) {
          twitterCallbacks.pushToGaq(intent_event);
        }
      },

      favIntentToAnalytics:function (intent_event) {
        twitterCallbacks.tweetIntentToAnalytics(intent_event);
      },

      retweetIntentToAnalytics:function (intent_event) {
        if (intent_event) {
          twitterCallbacks.pushToGaq(intent_event);
        }
      },

      followIntentToAnalytics:function (intent_event) {
        if (intent_event) {
          twitterCallbacks.pushToGaq(intent_event) ;
        }
      }
    };
    // Wait for the asynchronous resources to load
    twttr.ready(function (twttr) {
      // Now bind our custom intent events
      twttr.events.bind('click', twitterCallbacks.clickEventToAnalytics);
      twttr.events.bind('tweet', twitterCallbacks.tweetIntentToAnalytics);
      twttr.events.bind('retweet', twitterCallbacks.retweetIntentToAnalytics);
      twttr.events.bind('favorite', twitterCallbacks.favIntentToAnalytics);
      twttr.events.bind('follow', twitterCallbacks.followIntentToAnalytics);
    });
  });
});