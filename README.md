Hashblue.app
============

This is a proof-of-concept Mac OS X application that uses the #blue API and OAuth2 for authentication.


Getting it running
------------------

It uses MacRuby and at least one gem, which have yet to be 'vendored', so you might need to install both MacRuby and the gem:

    sudo macgem install json


Usage
-----

Once it has started, clicking the 'Load messages' button will send you to hashblue.com to authenticate. If you accept, it will then return to the application, and your messages will appear a few seconds later.


Notes
-----

This works because we can set the application to respond to a custom URI scheme (`hashblue:` in this case). This allows the redirect from the OAuth server to send data back to the application in the URL. This is pretty much the only nice user experience for a desktop application without actually embedding a user-agent (i.e. a browser).

At the moment the application does not store (or refresh) the OAuth token, but any decent application would do this to avoid having to authenticate after every launch.

`OAuthManager` does a bit of clever stuff to hide the authentication hoops from the rest of the app (`MyController`), but this could almost certainly be improved.