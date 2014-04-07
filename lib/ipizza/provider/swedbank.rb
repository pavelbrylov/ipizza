module Ipizza::Provider
  class Swedbank

    class << self
      attr_accessor :service_url, :return_url, :cancel_url, :file_key, :key_secret, :file_cert, :snd_id, :encoding
    end
    
    Id = 'swedbank'

    def payment_request(payment, service = 1002)
      req = Ipizza::PaymentRequest.new
      req.service_url = self.class.service_url
      req.sign_params = {
        'VK_SERVICE' => service.to_s,
        'VK_VERSION' => '008',
        'VK_SND_ID' => self.class.snd_id,
        'VK_STAMP' => payment.stamp,
        'VK_AMOUNT' => sprintf('%.2f', payment.amount),
        'VK_CURR' => payment.currency,
        'VK_REF' => Ipizza::Util.sign_731(payment.refnum),
        'VK_MSG' => payment.message
      }

      req.extra_params = {
        'VK_ENCODING' => self.class.encoding,
        'VK_RETURN' => self.class.return_url,
        'VK_CANCEL' => self.class.cancel_url
      }

      param_order = ['VK_SERVICE', 'VK_VERSION', 'VK_SND_ID', 'VK_STAMP', 'VK_AMOUNT', 'VK_CURR', 'VK_REF', 'VK_MSG']

      req.sign(self.class.file_key, self.class.key_secret, param_order, 'VK_MAC', Id)
      req
    end

    def payment_response(params)
      response = Ipizza::PaymentResponse.new(params)
      response.verify(self.class.file_cert, :encoding => self.class.encoding, :bank_name => Id, :snd_id => self.class.snd_id)
      return response
    end

    def authentication_request(service_no = 4002, return_url)
      req = Ipizza::AuthenticationRequest.new
      req.service_url = self.class.service_url
      req.sign_params = {
        'VK_SERVICE' => service_no,
        'VK_VERSION' => '008',
        'VK_SND_ID' => self.class.snd_id,
        'VK_REC_ID' => Id,
        'VK_NONCE' => SecureRandom.hex,
        'VK_RETURN' => return_url,
      }

      req.extra_params = {
        'VK_ENCODING' => self.class.encoding
      }

      param_order = [
        'VK_SERVICE', 
        'VK_VERSION', 
        'VK_SND_ID', 
        'VK_REC_ID', 
        'VK_NONCE', 
        'VK_RETURN'
      ]

      req.sign(self.class.file_key, self.class.key_secret, param_order)
      req
    end

    def authentication_response(params)
      response = Ipizza::AuthenticationResponse.new(params)
      response.verify(self.class.file_cert, :encoding => self.class.encoding, :bank_name => Id)
      return response
    end
  end
end
