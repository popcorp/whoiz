About WhoIz
===========

WhoIz is a simple WHOIS lookup application. It's built on Sinatra and Heroku friendly.

Fork by @PunKeel

Use It
======

JSON

    curl http://whoiz.herokuapp.com/yahoo.com


Clone It
========
    git clone git://github.com/popcorp/whoiz.git


Restrict It
===========

Edit

    main.rb

Change this

    before do
      response['Access-Control-Allow-Origin'] = '*'
    end

To this

    before do
      response['Access-Control-Allow-Origin'] = 'http://yourwebsite.com'
    end


Deploy It
=========
    heroku create
    git push heroku master
    heroku open


Run it
======
    bundle
    ruby main.rb
