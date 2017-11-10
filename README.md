# ex2mutt
To make mutt work with exchange, you have a lot of hoops to jump:
I put them in docker to spare you much bother


The container has the following packages
  - [davmail](http://davmail.sourceforge.net/)
  - [offlineimap](http://www.offlineimap.org/)
  - [msmtp](http://msmtp.sourceforge.net/)
  - [lynx](http://lynx.browser.org/)
  - [feh](https://feh.finalrewind.org/)
  - [python](https://www.python.org/)
    - install icalendar
additionally it
  - autostarts davmail
  - autostarts offlineimap
  - sets up mutt with
    - vim style keymappings
    - incoming and outgoing emails
    - viewable calendar invites
    - auto rendered html content via lynx
    - viewing of attached images via feh
    - querying of LDAP server for users/emails
    - general xdg-open for other files (mileage will very)

TODO:
  - sand out rough edges (PW visible at first prompt)
