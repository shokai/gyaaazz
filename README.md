gyaaazz
=======
gyazz like wiki system

- https://github.com/shokai/gyaaazz
- http://g.shokai.org


Dependencies
------------
- Ruby2.0.0+
- Mongoid 2.0+


Install Dependencies
--------------------

    % gem install bundler
    % bundle install


Config
------

    % sample.mongoid.yml mongoid.yml


Run
---

    % bundle exec rackup config.ru -p 5000

=> http://localhost:5000


### Auth

    % export BASIC_AUTH_USERNAME=user
    % export BASIC_AUTH_PASSWORD=pass
    % export RACK_ENV=production
    % bundle exec rackup config.ru -p 5000


Install as a Service
--------------------

for launchd (Mac OSX)

    % sudo foreman export launchd /Library/LaunchDaemons/ --app gyaaazz -u `whoami`
    % sudo launchctl load -w /Library/LaunchDaemons/gyaaazz-web-1.plist

for upstart (Ubuntu)

    % sudo foreman export upstart /etc/init/ --app gyaaazz -d `pwd` -u `whoami`
    % sudo service gyaaazz start
