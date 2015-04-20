require 'fedex/request/base'

module Fedex
  module Request
    # Obtain signature letter as proof of delivery
    #
    class SignatureLetter < Base

      attr_accessor :letter_format, :tracking_number, :comments

      def initialize(credentials, options={})
        requires!(options, :tracking_number)
        @tracking_number = options[:tracking_number]
        @account_number = options[:account_number]
        @letter_format = options[:letter_format] || 'PDF'
        @comments = options[:comments] || 'NONE'
        @file_name = options[:file_name] || "signature_letter_#{@tracking_number}.#{@letter_format.downcase}"
        @file_path = options[:file_path] || './'
        @credentials  = credentials
      end

      def process_request
        api_response = self.class.post(api_url, :body => build_xml)
        response = parse_response(api_response)
        if success?(response)
          save(Base64.decode64(response[:signature_proof_of_delivery_letter_reply][:letter]))
        else
          error_message = if response[:signature_proof_of_delivery_letter_reply]
            [response[:signature_proof_of_delivery_letter_reply][:notifications]].flatten.first[:message]
          else
            "#{api_response["Fault"]["detail"]["fault"]["reason"]}\n
            --#{api_response["Fault"]["detail"]["fault"]["details"]["ValidationFailureDetail"]["message"].join("\n--")}"
          end rescue $1
          raise RateError, error_message
        end
      end

      private

      def save(letter)
        file_path = File.join(@file_path, @file_name) 
        File.open(file_path, 'wb') do |f|
          f.write(letter)
        end
        file_path
      end

      def build_xml
        builder = Nokogiri::XML::Builder.new do |xml|
          xml.SignatureProofOfDeliveryLetterRequest(:xmlns => "http://fedex.com/ws/track/v#{service[:version]}") {
            add_web_authentication_detail(xml)
            add_client_detail(xml)
            add_version(xml)
            xml.QualifiedTrackingNumber {
              xml.TrackingNumber @tracking_number
              xml.AccountNumber @account_number
            }
            xml.LetterFormat @letter_format
          }
        end
        builder.doc.root.to_xml
      end

      def service
        { id: 'trck', version: 9 }
      end
      
      # Successful request
      def success?(response)
        response[:signature_proof_of_delivery_letter_reply] &&
          %w{SUCCESS WARNING NOTE}.include?(response[:signature_proof_of_delivery_letter_reply][:highest_severity])
      end
    end
  end
end
