# worker to run the pdf to html conversion in the background
class ConversionWorker
  @queue = 'conversion'
  def self.perform(file_to_process)
    file_name = File.basename(file_to_process.path).gsub(/\s+/, "")
    begin
      @conversion_response = RestClient.post "#{CONVERSION_SERVER}/#{file_name}", :data => File.new("#{file_to_process.path}")       
      if @conversion_response.code == 200
        @doc_name = save_file_name
        if @conversion_response.respond_to?(:body)
          resp = @conversion_response.body.split(':')
          @loc = resp[0]
          @pages = resp[1]
        end
      end
    rescue Exception => ex
      raise "The conversion service is unavailable or not responding at the moment! Exception info: #{ex.message} #{ex.backtrace.inspect}"
    end
  end
end