require 'spec_helper'

describe FontsController do
  it 'returns the remote font using the show action' do
  	session[:remote_url] = 'www.google.com'
    get :show_font, :name => 'test.woff'
    response.should be_redirect
  end
end