class StubResponse
  attr_reader :body
  
  def initialize(body)
    @body = body
  end
end