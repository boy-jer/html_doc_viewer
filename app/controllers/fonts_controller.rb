class FontsController < ApplicationController
  before_filter :clear_flash

  def show_font
    redirect_to "#{session[:remote_url]}fonts/#{params[:name]}"
  end
end