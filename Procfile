worker: bundle exec sidekiq -e production
worker: rake resque:work QUEUE=*
scheduler: rake resque:scheduler
