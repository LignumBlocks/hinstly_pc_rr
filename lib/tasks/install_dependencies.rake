# lib/tasks/install_dependencies.rake
namespace :install do
  desc "Instala Google Chrome y ChromeDriver"
  task chrome: :environment do
    system('wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb')
    system('sudo apt install ./google-chrome-stable_current_amd64.deb')
    chromedriver_version = `curl -sS https://chromedriver.storage.googleapis.com/LATEST_RELEASE`.strip
    system("wget https://chromedriver.storage.googleapis.com/#{chromedriver_version}/chromedriver_linux64.zip")
    system('unzip chromedriver_linux64.zip')
    system('sudo mv chromedriver /usr/local/bin/')
    system('sudo chmod +x /usr/local/bin/chromedriver')
  end
end
