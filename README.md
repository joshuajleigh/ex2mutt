# ex2mutt
Make mutt work with exchange, with style

Install the following packages
  - [davmail](http://davmail.sourceforge.net/)
  - [offlineimap](http://www.offlineimap.org/)
  - [msmtp](http://msmtp.sourceforge.net/)
  - [xdg-open](https://linux.die.net/man/1/xdg-open)
  - [lynx](http://lynx.browser.org/)
  - [feh](https://feh.finalrewind.org/)
  - [perl](https://www.perl.org/)
    - install Net::LDAP perl module `cpan Net::LDAP`
  - [python](https://www.python.org/)
    - install icalendar

type `make ithappen`

Now you should have the following
  - davmail autostarting
  - offline imap auto syncing
  - mutt being all stylish with
    - vim style keymappings
    - incoming and outgoing emails
    - viewable calendar invites
    - auto rendered html content via lynx
    - viewing of attached images via feh
    - querying of LDAP server for users/emails
    - general xdg-open for other files
