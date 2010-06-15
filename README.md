# ticketmaster-lighthouse

This is a provider for [ticketmaster](http://ticketrb.com). It provides interoperability with (Lighthouse)[http://www.lighthouseapp.com/] through the ticketmaster gem.

# Usage and Examples

First we have to instantiate a new ticketmaster instance:
    lighthouse = TicketMaster.new(:lighthouse, {:subdomain => "rails"})
    lighthouse = TicketMaster.new(:lighthouse, {:username => "code", :password => "m4st3r!", :account => "ticketmaster"})
    lighthouse = TicketMaster.new(:lighthouse, {:token => "5ff546af3df4a3c02d3a719b0ff1c3fcc5351c97", :account => "lhdemo"})

The :account is the name of the account which should be the same as the subdomain used to access the account's projects. For you convenience, you can also pass in :subdomain in place of :account. If you pass in both, it'll use the :account value. If you do not pass in the token or both the username and password, it will only access public information for the account.

Tokens allow access to a specific project or account without having to give out your login credentials. It can be nullified if necessary. I highly suggest you use tokens. For more information, please see Lighthouse's FAQ (How do I get an API token?)[http://help.lighthouseapp.com/faqs/api/how-do-i-get-an-api-token]

== Finding Projects

    project = lighthouse.project

## Requirements

* rubygems (obviously)
* ticketmaster gem (latest version preferred)
* jeweler gem (only if you want to repackage and develop)

The ticketmaster gem should automatically be installed during the installation of this gem if it is not already installed.

## Other Notes

Since this and the ticketmaster gem is still primarily a work-in-progress, minor changes may be incompatible with previous versions. Please be careful about using and updating this gem in production.

If you see or find any issues, feel free to open up an issue report.


## Note on Patches/Pull Requests
 
* Fork the project.
* Make your feature addition or bug fix.
* Add tests for it. This is important so I don't break it in a
  future version unintentionally.
* Commit, do not mess with rakefile, version, or history.
  (if you want to have your own version, that is fine but bump version in a commit by itself I can ignore when I pull)
* Send me a pull request. Bonus points for topic branches.

## Copyright

Copyright (c) 2010 HybridGroup. See LICENSE for details.
