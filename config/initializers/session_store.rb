# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_clarity_session',
  :secret      => 'c4ef372760421d3cb56c31978cf3289a96f8c925a67da9fcfcc8b57158af29c041753633e68a0d77c40cf7e305305fc98e46d8c6f5493572e76c208a7abf1fa1'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
