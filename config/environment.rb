
# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
HtmlDocViewer::Application.initialize!

CONVERSION_SERVER = ENV['CONV_SERVER']