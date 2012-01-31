class ConversionsController < ApplicationController
  before_filter :clear_flash, :only => [:new, :create, :result, :show]
  before_filter :get_resource, :only => [:result, :show, :fetch_html, :query_status]
  before_filter :ping_service, :only => [:new, :create]
  layout 'application', :only => [:new, :create, :result, :show]
  
  def new
    @conversion = Conversion.new
  end
  
  def create
    if params[:document_file] && File.exists?(params[:document_file].tempfile)
      file_name = params[:document_file].original_filename
      @conversion = Conversion.create({:document_name => file_name, :document_path => "#{Rails.root}/tmp/#{file_name}", :uploaded_at => Time.now, :document_content => params[:document_file].tempfile})
      respond_to do |format|
        format.html {render 'result'}
      end
    else
      flash[:error] = 'No file was chosen!'
      @conversion = Conversion.new
      respond_to do |format|
        format.html {render 'new'}
      end
    end
  end
  
  def result
  end
  
  def show
    @url = "#{fetch_html_conversion_url(@conversion.id)}?fetch_url=#{CONVERSION_SERVER}/#{@conversion.location}/#{@conversion.stripped_document_name_without_ext}"
    session[:remote_url] = "#{CONVERSION_SERVER}/#{@conversion.location}/"   
  end
  
  def fetch_html
    begin 
      @resp = RestClient.get params[:fetch_url] 
    rescue 
      @resp = '' 
    end
  end
  
  def fetch_font
    redirect_to "#{session[:remote_url]}fonts/#{params[:name]}"
  end

  def fetch_image
    redirect_to "#{session[:remote_url]}#{params[:file]}/#{params[:img]}" 
  end
  
  def query_status
    response = @conversion.converted? ? 'complete' : 'incomplete'
    respond_to do |format| 
      format.html {render :text => response, :status => 200}
    end
  end
  
  private
  
  def ping_service
    @service_available = begin RestClient.get(CONVERSION_SERVER) == "hello world" ? true : false rescue false end
  end
  
  def get_resource
    unless params[:id].blank?
      @conversion = Conversion.find(params[:id]) 
    end
  end
end
