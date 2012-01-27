require 'spec_helper'

describe Conversion do
  
  before(:each) do
    Resque.redis.del "queue:conversion"
  end
  
  after(:each) do
    Resque.redis.del "queue:conversion"
  end

  
  it {should validate_presence_of(:document_name)}
  it {should validate_presence_of(:document_path)}
  it {should validate_presence_of(:uploaded_at)}
  
  it 'should alias the converted attribute' do
    @conversion = Factory(:conversion)
    @conversion.converted.should be_false
    @conversion.converted?.should == @conversion.converted
  end
  
  it 'should return the stripped document name without extension' do
    @conversion = Factory(:conversion, :document_name => 'test convert.pdf')
    @conversion.stripped_document_name_without_ext.should == 'testconvert'
  end
  
  it 'should return the document name stripped of spaces' do
    @conversion = Factory(:conversion, :document_name => 'test convert 2.pdf')
    @conversion.stripped_document_name.should == 'testconvert2.pdf'
  end
  
  describe 'process after create' do
    before(:all) do
      @file = "#{Rails.root}/spec/fixtures/test.pdf"
    end
    
    it 'should successfully process conversion post creation' do
      RestClient.stub!(:post).and_return('3233-12212-1:2') if STUB_CONVERSION
      @conversion = Factory(:conversion, :document_content => @file)
      Resque.size(:conversion).should > 0
    end
    
    it 'should fail processing conversion post creation' do
      RestClient.stub!(:post).and_return(nil) if STUB_CONVERSION
      @conversion = Factory(:conversion, :document_content => @file)
      Resque.size(:conversion).should > 0
      @conversion.converted?.should be_false
      @conversion.location.should be_nil
      @conversion.num_of_pages.should be_nil
    end
  end
end
