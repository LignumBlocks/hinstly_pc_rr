web: bundle exec puma -C config/puma.rb
worker_sidekiq: bundle exec sidekiq -e production
worker_resque: rake resque:work QUEUE=*
scheduler: rake resque:scheduler