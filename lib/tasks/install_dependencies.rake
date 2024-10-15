# lib/tasks/install_dependencies.rake
namespace :install do
  desc 'Instala Google Chrome y ChromeDriver'
  task chrome: :environment do
    system('wget https://storage.googleapis.com/chrome-for-testing-public/129.0.6668.100/linux64/chrome-linux64.zip')
    system('sudo apt install ./google-chrome-stable_current_amd64.deb')
    system('wget https://storage.googleapis.com/chrome-for-testing-public/129.0.6668.100/linux64/chromedriver-linux64.zip')
    system('unzip chromedriver-linux64.zip')
    system('sudo mv chromedriver-linux64 /usr/local/bin/')
    system('sudo chmod +x /usr/local/bin/chromedriver-linux64')
  end
end