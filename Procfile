web: bundle exec puma -C config/puma.rb
worker_sidekiq1: bundle exec sidekiq -e production -c ${SIDEKIQ_CONCURRENCY:-7}
worker_sidekiq2: bundle exec sidekiq -e production -c ${SIDEKIQ_CONCURRENCY:-7}
worker_resque: rake resque:work QUEUE=*
scheduler: rake resque:scheduler