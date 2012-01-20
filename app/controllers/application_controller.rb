class ApplicationController < ActionController::Base
  protect_from_forgery

  protected
  
  def clear_flash
    flash.clear
  end
end
