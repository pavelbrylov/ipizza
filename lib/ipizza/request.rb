module Ipizza
  class Request
    
    attr_accessor :extra_params
    attr_accessor :sign_params
    attr_accessor :service_url
    
    def sign(privkey_path, privkey_secret, order, mac_param = 'VK_MAC', bankname = nil)
      signature = Ipizza::Util.sign(privkey_path, privkey_secret, Ipizza::Util.mac_data_string(sign_params, order, bankname))
      self.sign_params[mac_param] = signature
    end
    
    def request_params
      sign_params.merge(extra_params)
    end
  end
end