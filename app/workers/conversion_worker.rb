# worker to run the pdf to html conversion in the background
class ConversionWorker
  @queue = :conversion
  def self.perform(conversion_id)
    conversion = Conversion.find(conversion_id)
    begin
      conversion_response = RestClient.post "#{CONVERSION_SERVER}/#{conversion.stripped_document_name}", :data => File.new("#{conversion.document_path}")       
      unless conversion_response.blank?
        resp = conversion_response.split(':')
        self.location = resp[0]
        self.num_of_pages = resp[1].to_i
        self.converted = true
      else
        self.converted = false
      end
      conversion.save
    rescue Exception => ex
      self.converted = false
    end
  end
end