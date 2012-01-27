require 'spec_helper'

describe ConversionsController do
  render_views
  
  before(:each) do
    Resque.redis.del "queue:conversion"
  end
  
  after(:each) do
    Resque.redis.del "queue:conversion"
  end
  
  describe 'new' do
    it 'return a new conversion page with success when service is available' do
      RestClient.stub!(:get).and_return("hello world") if STUB_CONVERSION
      get :new
      response.should be_success
      response.should render_template(:new)
      assigns(:service_available).should be_true
      assigns(:conversion).should_not be_nil
    end

    it 'return a new conversion page with exception when service is not available' do
      RestClient.stub!(:get).and_return("not found") if STUB_CONVERSION
      get :new
      response.should be_success
      response.should render_template(:new)
      assigns(:service_available).should be_false
      assigns(:conversion).should_not be_nil
    end
  end
  
  describe 'show' do
    before(:each) do
      @conversion = Factory(:conversion)
    end
    it 'shows the converted document with success' do
      @conversion.update_attributes({:converted => true, :location => '1ef18bea-2d6f-408e-a742-3ddbd8c1d69e', :num_of_pages => 3})
      get :show, :id => @conversion.id
      response.should be_success
      response.should render_template(:show)
      assigns(:url).should == "#{fetch_html_conversion_url(@conversion)}?fetch_url=#{CONVERSION_SERVER}/1ef18bea-2d6f-408e-a742-3ddbd8c1d69e/test"
    end

    it 'shows an exception for document conversion' do
      @conversion.update_attributes({:converted => false, :num_of_pages => nil})
      get :show, :id => @conversion.id
      response.should be_success
      response.should render_template(:show)
      response.body.include?('Sorry').should be_true
    end

    # it 'show a document with the stubbed viewer' do
    #       get :show, {:doc_name => 'seemework', :pages => '2', :stub => true}
    #       response.should be_success
    #       response.should render_template(:display)
    #       assigns(:doc_name).should == 'seemework'
    #       assigns(:pages).should == 2
    #       assigns(:url).should == "#{root_url}seemework"
    #     end
  end
  
  it 'returns the conversion result page with success' do
    @conversion = Factory(:conversion, :converted => true)
    get :result, :id => @conversion.id
    response.should be_success
    response.should render_template(:result)
  end
  
  it 'fetches the html content using the URL with success' do
    @conversion = Factory(:conversion, :converted => true)
    get :fetch_html, {:id => @conversion.id, :fetch_url => 'http://test.host/422.html'}
    response.should be_success
  end
  
  it 'fetches the remote image by routing appropriately' do
    get :fetch_image, {:file => 'test2-1', :img => 'img@3456x12672w10373h4959-16dpi.jpg'}
    response.should be_redirect
  end
  
  it 'fetches the remote font by routing appropriately' do
    get :fetch_font, {:name => 'test.woff'}
    response.should be_redirect
  end
  
  describe 'create' do
    before(:each) do
      RestClient.stub!(:get).and_return("hello world") if STUB_CONVERSION 
      @test_document = fixture_file_upload('/test.pdf', 'application/pdf')
      class << @test_document #hack to simulate the file upload action
         attr_reader :tempfile
      end   
    end
    
    it 'should not create/process a conversion without a file uploaded to the server' do
      post :create, {}
      response.should be_success
      response.should render_template(:new)
      assigns(:conversion).should_not be_nil
    end
    
    it 'should create/process a conversion successfully' do
      RestClient.stub!(:post).and_return('success') if STUB_CONVERSION
      post :create, {:document_file => @test_document}
      response.should be_success
      response.should render_template(:result)
      Resque.size(:conversion).should > 0
      assigns(:conversion).should_not be_nil
      assigns(:conversion).document_name == 'test.pdf'
    end
    
    it 'should create/process a conversion without success' do
      RestClient.stub!(:post).and_return(nil) if STUB_CONVERSION
      post :create, {:document_file => @test_document}
      response.should be_success
      response.should render_template(:result)
      Resque.size(:conversion).should > 0
      assigns(:conversion).should_not be_nil
      assigns(:conversion).document_name == 'test.pdf'
      assigns(:conversion).converted?.should be_false
      assigns(:conversion).location.should be_nil
      assigns(:conversion).num_of_pages.should be_nil
    end

    describe 'conversion with spaced file name' do
      before(:each) do
        @test_document = fixture_file_upload('/Sivasankari Ranganathan.pdf', 'application/pdf')
        class << @test_document #hack to simulate the file upload action
          attr_reader :tempfile
        end
      end

      it 'should create/process a conversion successfully' do
        RestClient.stub!(:post).and_return('success') if STUB_CONVERSION
        post :create, {:document_file => @test_document}
        response.should be_success
        response.should render_template(:result)
        Resque.size(:conversion).should > 0
        assigns(:conversion).should_not be_nil
        assigns(:conversion).document_name == 'Sivasankari Ranganathan.pdf'
      end
    end
  end
end


