# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_zaan_session',
  :secret      => 'dc72d821b15aa6b54de138dc53c87923e9f19fc96c22449ef5e039625e61d1f641aa226fc7073567ddbc5aaa22bdd85ad4ffe162ee5ed7819a448cf7948ab5ec'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
