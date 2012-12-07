var twitterWidget = {
  extractURL: function(target) {
    if (target && target.nodeName == 'A') {
      return twitterWidget.extractParamFromUri(target.href, 'url');
    }
    else {
      return null;
    }
  },

  // take the twitter intent link and extract the share URL from the parameters being passed to that URL.
  // really twitter, you could not have just put this in the intent hash?
  extractParamFromUri: function(uri, paramName) {
    if (!uri) return;
    var regex = new RegExp('[\\?&#]' + paramName + '=([^&#]*)');
    var params = regex.exec(uri);
    if (params != null) {
      return decodeURI(params[1]);
    }
    return;
  },

  pushToGaq: function(intent_event) {
    if (typeof _gaq !== "undefined" && _gaq !== null) {
      _gaq.push(['_trackEvent', 'twitter', intent_event.type, twitterWidget.extractURL(intent_event.target)]);
    }
  },
  
  handlers: {
    // Define our custom event hanlders
    click: function(intent_event) {
      if (intent_event) {
        twitterWidget.pushToGaq(intent_event);
        twitterWidget.callbacks.click(intent_event);
      }
    },
    tweet: function(intent_event) {
      if (intent_event) {
        twitterWidget.pushToGaq(intent_event);
        twitterWidget.callbacks.tweet(intent_event);
      }
    },
    favorite: function(intent_event) {
      if (intent_event) {
        twitterWidget.pushToGaq(intent_event);
        twitterWidget.callbacks.favorite(intent_event);
      }
    },
    retweet: function(intent_event) {
      if (intent_event) {
        twitterWidget.pushToGaq(intent_event);
        twitterWidget.callbacks.retweet(intent_event);
      }
    },
    follow: function(intent_event) {
      if (intent_event) {
        twitterWidget.pushToGaq(intent_event) ;
        twitterWidget.callbacks.follow(intent_event);
      }
    }
  },
  
  callbacks: {
    click:    function(intent_event) {},
    tweet:    function(intent_event) {},
    favorite: function(intent_event) {},
    retweet:  function(intent_event) {},
    follow:   function(intent_event) {}
  }
};

$(function() {
  $.getScript('//platform.twitter.com/widgets.js', function () {
    twttr.ready(function (twttr) {
      twttr.events.bind('click',    twitterWidget.handlers.click);
      twttr.events.bind('tweet',    twitterWidget.handlers.tweet);
      twttr.events.bind('retweet',  twitterWidget.handlers.retweet);
      twttr.events.bind('favorite', twitterWidget.handlers.favorite);
      twttr.events.bind('follow',   twitterWidget.handlers.follow);
    });
  });
});