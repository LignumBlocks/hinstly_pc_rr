web: bundle exec puma -C config/puma.rb
worker_sidekiq: bundle exec sidekiq -e production -c ${SIDEKIQ_CONCURRENCY:-10}
worker_resque: rake resque:work QUEUE=*
scheduler: rake resque:scheduler