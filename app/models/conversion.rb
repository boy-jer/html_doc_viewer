class Conversion < ActiveRecord::Base
  attr_accessor :document_content
  validates_presence_of :document_name, :document_path, :uploaded_at
  after_create :process
  alias_attribute :converted?, :converted
  
  def stripped_document_name_without_ext
    self.stripped_document_name.gsub('.pdf', '')
  end
  
  def stripped_document_name
    self.document_name.gsub(/\s+/, "")
  end
  
  private
  
  def process
    return if self.document_content.blank?
    # persist the file
    save_file = File.new(self.document_path, 'w')
    File.open(self.document_content, 'r') do |f|
      save_file.write(f.read)
    end
    save_file.close
    Delayed::Job.enqueue ConversionJob.new(self.id) #queue a conversion job to process the conversion
  end
end
