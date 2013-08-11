web: bundle exec rails server -p $PORT -e development
sphinx: bundle exec rake --trace ts:foreground
worker: env VERBOSE=1 QUEUE=* bundle exec rake --trace resque:work
