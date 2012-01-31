# delayed_job worker to run the pdf to html conversion in the background
class ConversionJob < Struct.new(:conversion_id)
  def perform
    conversion = Conversion.find(conversion_id)
    begin
      conversion_response = RestClient.post "#{CONVERSION_SERVER}/#{conversion.stripped_document_name}", :data => File.new("#{conversion.document_path}")       
      unless conversion_response.blank?
        resp = conversion_response.split(':')
        conversion.location = resp[0]
        conversion.num_of_pages = resp[1].to_i
        conversion.converted = true
      else
        conversion.converted = false
      end
    rescue Exception => ex
      conversion.converted = false
    ensure
      conversion.save
    end
  end
end