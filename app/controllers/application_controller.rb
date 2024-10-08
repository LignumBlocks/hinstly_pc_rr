class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to request.referer || root_path, alert: exception.message
  end
end
