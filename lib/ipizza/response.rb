class Ipizza::Response

  attr_accessor :verify_params
  attr_accessor :verify_params_order
  
  @@response_param_order = {
    '1101' => ['VK_SERVICE', 'VK_VERSION', 'VK_SND_ID', 'VK_REC_ID', 'VK_STAMP', 'VK_T_NO', 'VK_AMOUNT', 'VK_CURR', 'VK_REC_ACC', 'VK_REC_NAME', 'VK_SND_ACC', 'VK_SND_NAME', 'VK_REF', 'VK_MSG', 'VK_T_DATE'],
    '3002' => ['VK_SERVICE', 'VK_VERSION', 'VK_USER', 'VK_DATE', 'VK_TIME', 'VK_SND_ID', 'VK_INFO'],
    '3003' => ['VK_SERVICE', 'VK_VERSION', 'VK_SND_ID', 'VK_REC_ID', 'VK_NONCE', 'VK_INFO'],
    '1901' => ['VK_SERVICE', 'VK_VERSION', 'VK_SND_ID', 'VK_REC_ID', 'VK_STAMP', 'VK_REF', 'VK_MSG'],
    '1902' => ['VK_SERVICE', 'VK_VERSION', 'VK_SND_ID', 'VK_REC_ID', 'VK_STAMP', 'VK_REF', 'VK_MSG', 'VK_ERROR_CODE']
  }  
  
  def initialize(params)
    @params = params
  end

  def verify(certificate_path, options = {})
    begin
      bank_name = options[:bank_name] if options
      snd_id = options[:snd_id] if options
      
      param_order = @@response_param_order[@params['VK_SERVICE']]
      verify_params = param_order.inject(Hash.new) { |h, p| h[p] = @params[p]; h }
      mac_string = Ipizza::Util.mac_data_string(verify_params, param_order, bank_name)

      signature_valid = Ipizza::Util.verify_signature(certificate_path, @params['VK_MAC'], mac_string)      
      snd_valid = (snd_id.nil? || snd_id == "") ? true : snd_id == @params['VK_REC_ID']
      
      @valid = signature_valid && snd_valid
    rescue => e
      raise e
      @valid = false
    end
  end
end
