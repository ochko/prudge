web: bundle exec rails server -p $PORT -e development
sphinx: bundle exec rake ts:foreground
worker: env QUEUE=* bundle exec rake resque:work
