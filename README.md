# email-updates
A script that is intended to be run periodically on a GNU/Linux box to report any new updates since the last report. Previously reported updates are saved to a local SQLite db for (relatively) easy review.

## Custom Settings

"Out of the box", `email_updates.sh` comes preconfigured with most settings ready for use, but prior to `v0.2.5` you had to modify the script directly to set common values like email address. With `v0.2.5`, you do this through a custom configuration file.


  `/etc/whyaskwhy.org/email_updates.conf`

### Supported settings

* `1` = setting is enabled
* `0` = setting is *disabled*.


#### DEBUG_ON

*placeholder*
