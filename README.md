About WhoIz
===========

WhoIz is a simple WHOIS lookup application. It's built on Sinatra and Heroku friendly.

Fork by @PunKeel

Use It
======

JSON

    curl http://whoiz.herokuapp.com/raw/yahoo.com
    curl http://whoiz.herokuapp.com/raw/?domain=yahoo.com

    curl http://whoiz.herokuapp.com/available/yahoo.com
    curl http://whoiz.herokuapp.com/available/?domain=yahoo.com

    curl http://whoiz.herokuapp.com/available/yahoo/com,eu,fr,nf,sh,ws
    curl http://whoiz.herokuapp.com/available/?domain=yahoo.com&extensions=eu,com,fr,ws


Clone It
========
    git clone git://github.com/popcorp/whoiz.git


Run it
======
    bundle
    ruby main.rb
