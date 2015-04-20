require 'spec_helper'

module Fedex
  describe Shipment do
    let (:fedex) { Shipment.new(fedex_credentials) }
    context "#proof_of_delivery_letter", :vcr do
      let(:options) do
        { :tracking_number => '634370115347',
          :account_number => 'XXXXXXXXX'
        }
      end
      it "should get a signature letter" do
        expect{ fedex.signature_letter(options) }.to_not raise_error
      end
    end
  end
end
