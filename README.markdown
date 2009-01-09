`http_to_campfire`
==================

A lil' web app to act as a centralized RESTful endpoint for your scripts that
post to Campfire. You POST, it posts.

Basic idea:

1. Setup a handler for your service (say, post-commit callbacks from GitHub)
2. Write a small template to interpolate the variables into Campfire posts

That's it.