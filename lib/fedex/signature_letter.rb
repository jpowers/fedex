require 'pathname'

module Fedex
  class SignatureLetter
    attr_accessor :options, :letter, :response_details
    
    def initialize(signature_details, options = {})
      @letter = Base64.decode64(signature_details[:signature_proof_of_delivery_letter_reply][:letter]))
    end


    def save(path)
      file_path = File.join(@file_path, @file_name) 
      File.open(file_path, 'wb') do |f|
        f.write(letter)
      end
    end
    

  end
end
