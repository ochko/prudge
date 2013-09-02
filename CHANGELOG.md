# CHANGELOG

## 2013-09-01
 * Code check will be processed in the background
 * Removed counter_cache columns
 * Added foreman for starting all required processes
 * Resque for background processing
 * Removed contest level, problem level and private contest
 * Added fingerprint to solutions
 * Using output file instead db column
 * More localizations extracted
 * erb --> haml
 * Using prettify for source code display
 * Show only first 1 kilbytes of test result
 * Added posts and removed pages, topics and lessons resources
 * Separated abilities by role
 * It is possible to solve problem with all tests visible
 * Removed rss feeds
 * Removed best solution and solved solutions tabs, use table sorter
 * Some mobile browser friendliness
 * Sleek view for users ranking
 * Deleted atom_feed_helper plugin
 * Replaced legacy auto_complete plugin with bootstrap typeahead
 * Replace plugin with wmd editor gem
 * Rename rhtml to html.erb
 * Simpler list on user profile
 * Replaced will_paginate with kaminari
 * User profile page re-desinged
 * Languages are no longer AR, now in config
 * Delete all social column except web and twitter
 * Replaced blueprint with bootstrap
 * Major UI redesign
 * Upgrade to Rails 3.2, Ruby 1.9.3
 * Asset pipeline
 * Store test data with paperclip(out of db)
 * CanCan for authorization
 * Update rails gem to 2.3.18

## 2011-11-29
 * Removed google ad. not being clicked nor being noticed by coders :(
 * Twitter announcement added
 * Using delayed job for new contest notification
 * Added new kind of contest -- contributors only private contest
 * Using haml as templating enginge
 * Added support for script languages(ruby, python)
 * Using bundler for managing gem versions
 * Google adsense :P
 * Using web font
 * Take first solved time as a time
 * Sponsors added
 * Limit output file size
 * Hide inactive problems on search page
 * Level is changed to power of 2
 * Ingore white spaces when comparing results
 * Rails gem version upgraded to 2.3.8
 * Harsh is replaced by jquery.syntax
 * problem points are power of 2
 * Comments added per solution
 * Installed exception notification
 * Customized HTTP error pages
 * Scrooge is used for loading only needed columns
 * Social media infor added to user profiles
 * Harsh plugin for code styling
 * Started using local git repo per user

## 2010-05-31
 * Notification mailer new release
 * Added favicon
 * Show only output of compile error
 * Show diff of results
 * Replaced attachment_fu with paperclip and attachment model removed
 * Twitter like flow pagination
 * Use ajax for user tab
 * Removed in_place_editing and respont_to_parent
 * Homeworks removed from lessons
 * Sanitized users listing
 * Comment moderation added
 * Search feature added using thinking_sphinx
 * Removed plugins acts_as_authenticated, acl_system2, acts_as_rateable
 * Using jrails
 * OpenID is added by open_id_authentication plugin
 * Tabbed view for user page
 * Removed banner configurable banner
 * Removed contest types
 * Removed whole course organization section
 * Removed tasks and fullfillments section
 * Removed student workgroups
 * Removed polls
 * Removed prizes
 * Removed problem types
 * Removed Questions & Answers section
 * Removed ratings feature
 * Removed sponsors section
 * Removed some files in scripts/* from old rails version
 * Removed some plugins acts_as_taggable, classic_pagination, acts_as_textiled, fckeditor, interlock, limited_sessions, mini_magick, ssl_requirement, textile_editor

## 2010-05
 * Copied from SVN repository
 * Upgraded to Rails 2.1.1

## 2007-11-25
 * SVN Repository created
 * Application created with Rails 1.2