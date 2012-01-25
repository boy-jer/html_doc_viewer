Factory.define :conversion do |c|
  c.document_name 'test.pdf'
  c.document_path  "#{Rails.root}/tmp/test.pdf"
  c.document_content nil
  c.uploaded_at Time.now
  c.converted false
end