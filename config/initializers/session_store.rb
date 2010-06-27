# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_tumblr2epub_session',
  :secret      => '245019665097c4248025c841c5671c2e08fbaa72612502a7487c010b67f0d0f4b8d2b3b2ddafd9d84478a36e6718a3e9e79fee4c066ba190c8b26890b6002387'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
