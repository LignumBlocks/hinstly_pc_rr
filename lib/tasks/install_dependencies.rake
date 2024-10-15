# lib/tasks/install_dependencies.rake
namespace :install do
  desc 'Instala Google Chrome y ChromeDriver'
  task chrome: :environment do
    system('wget https://storage.googleapis.com/chrome-for-testing-public/131.0.6777.2/linux64/chrome-linux64.zip')
    system('sudo apt install ./google-chrome-stable_current_amd64.deb')
    system('wget https://chromedriver.storage.googleapis.com/131.0.6777.2/chromedriver_linux64.zip')
    system('unzip chromedriver_linux64.zip')
    system('sudo mv chromedriver /usr/local/bin/')
    system('sudo chmod +x /usr/local/bin/chromedriver')
  end
end
