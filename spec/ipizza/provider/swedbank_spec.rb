# -*- encoding: utf-8 -*-
require 'time'
require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Ipizza::Provider::Swedbank do
  describe '#payment_request' do
    before(:each) do
      @payment = Ipizza::Payment.new(:stamp => 1, :amount => '123.34', :refnum => 1, :message => 'Payment message', :currency => 'EUR')
    end
    
    it 'signs the request' do
      req = Ipizza::Provider::Swedbank.new.payment_request(@payment)
      req.sign_params['VK_MAC'].should == 'lmy2ApT7Z5XnidrAw6C9sfPHaDTh5y0vco9wJuG71BpYYnGN8sfbWgiNwpQOoNeZV00MdchePknxswPsSsG4G5m3/V1m+VL+zAKw8nLvC3WGpfL4JYn4wx61U8Axn8loPq5qHzgSYASLb/rsbeP4ep91AGSLa+dUgpF2m2sTmeu5/us1r4CIqvTkUj0XkdKi1lFOMkDMbdoAeQSnfIRp7nJ4jTRXBY4v2HcTYDh55bv/jEhvQOFaM9nggHysj2hRNMWfxgrfE1s/e93cBzS643X43a9HOndUvv5FI0VdTaUKqudIdINy5sSdSa7lSW+8gzDDD3H+BZ0o6G1bgQaeTg=='
    end
  end

  describe '#payment_response' do
    context 'valid receiver id' do
      before do
        @params = {
          'VK_T_NO' => '587', 'encoding' => 'UTF-8', 'VK_REC_ID' => 'fraktal', 'VK_REF' => '201107010000080',
          'VK_SND_NAME' => Iconv.conv('ISO-8859-4', 'UTF-8', 'TÕNU RUNNEL'), 'VK_T_DATE' => '01.07.2011', 'VK_STAMP' => '20110701000008', 'VK_SND_ACC' => '1108126403',
          'VK_LANG' => 'EST', 'VK_SERVICE' => '1101', 'VK_REC_NAME' => Iconv.conv('ISO-8859-4', 'UTF-8', 'FRAKTAL OÜ'), 'VK_AMOUNT' => '0.17',
          'VK_MSG' => 'Edicy invoice #20110701000008', 'VK_AUTO' => 'N', 'VK_SND_ID' => 'HP', 'VK_VERSION' => '008', 'VK_ENCODING' => 'ISO-8859-4',
          'VK_REC_ACC' => '221038811930', 'VK_CURR' => 'EUR',
          'VK_MAC' => 'geOA+gjLJlFouGMih0WhbQwTehZM1FVus1OhO34yt8shekINWOzUi6gLymq9HYSDIAx/Gw2iUOKGxzhCRsXu3fxjVVlXpS9YRQfFF8HG1zoU2OUiNBZVa+7bGGDLOy+ZIhnyaW1I3jIFXHd57xDyCVCQvB0Ot4Ya9yE3YMKHTk4='
        }
      
        Ipizza::Provider::Swedbank.file_cert = File.expand_path('../../../certificates/swedbank_production.pem', __FILE__)
      end
    
      it 'parses and verifies the payment response from bank' do
        Ipizza::Provider::Swedbank.new.payment_response(@params).should be_valid
      end
    end
    
    context 'invalid receiver id' do
      before do
        @params = {
          'VK_T_NO' => '61', 'encoding' => 'UTF-8', 'VK_REC_ID' => 'AVOR', 'VK_REF' => '3130091546',
          'VK_SND_NAME' => Iconv.conv('ISO-8859-4', 'UTF-8', 'HELE TALU'), 'VK_T_DATE' => '29.07.2013', 'VK_STAMP' => '1300915', 'VK_SND_ACC' => '221010328014',
          'VK_LANG' => 'EST', 'VK_SERVICE' => '1101', 'VK_REC_NAME' => 'AVOR KINDLUSTUSMAAKLER OÜ', 'VK_AMOUNT' => '1.00',
          'VK_MSG' => 'Arve 1300915, 906MLG kaskokindlustus.', 'VK_AUTO' => 'Y', 'VK_SND_ID' => 'HP', 'VK_VERSION' => '008', 'VK_ENCODING' => 'UTF-8',
          'VK_REC_ACC' => '221047583000', 'VK_CURR' => 'EUR',
          'VK_MAC' => 'raCFs6LYla0zDgHIqIYqSBJpDAbovAmBg9gKsfO/A7DjLEZGJesGu+QexOArMs/f0iAL9ddweKK7piHLEZjCUDqBT8Uxum31LcAR73XcDfb3+eDNPsWMDFDswO9ewT+XHgnaWfG7qtK6dW/8OM3tWvpWnOnDzA9VQTK32F833EI='
        }

        Ipizza::Provider::Swedbank.file_cert = File.expand_path('../../../certificates/swedbank_production_v2.pem', __FILE__)
      end

      it 'parses and verifies the payment response from bank' do
        Ipizza::Provider::Swedbank.new.payment_response(@params).should_not be_valid
      end      
    end
  end

  describe '#authentication_request' do
    before(:each) do
      Time.stub(:now).and_return(Time.parse("Mar 30 1981"))
      Date.stub(:today).and_return(Date.parse("Mar 30 1981"))
    end
    
    it 'should sign the request' do
      req = Ipizza::Provider::Swedbank.new.authentication_request
      req.sign_params['VK_MAC'].should == 'K7CEsDNfGq6/Cd6BazligbF2tM2EmXt6ykdY2Uxe8MAHaoZXsd+yM9jcRIHKIl9rPv8vQ/krJtuWHtVB3xzYHhkhdyuXUCgTngs0HEJG/Zntu6z3CsgdyZGCLcuw3tM6wz0Sg6PFwu1jqiNAV6TE2SMHMvEy/ii2ZBB2hs0AvCnYsP3z5ouZPoUymo5XSBGccTsdTNXphK57p1sCfwKUbCEdFTuDnvr/Aj0HFLqNpM+42UhZDZSJRDtcGyxJqFpXTvYHXdBytD1rMPJeEOZOAx90KZDZWwh+IDxoDTL4gfubDm9REqBCBf3HrHUOMPK817HDcM9iSC82h1zhk0/OVQ=='
    end
  end
  
  describe '#authentication_response' do
    before(:each) do
      @params = {
        'VK_SERVICE' => '3002', 'VK_VERSION' => '008', 'VK_USER' => 'dealer',
        'VK_DATE' => '30.03.1981', 'VK_TIME' => '00:00:00', 'VK_SND_ID' => 'SWEDBANK',
        'VK_INFO' => 'ISIK:37508166516;NIMI:JAAN SAAR',
        'VK_MAC' => 'ds/a+lwQhq1cs34mCqbpkNkXt/6fHwxii5+G+qA9vbhic/6TUnkIiJK+gFUZzMgRKDxOiOTD44zK7P9v58G972YbNvI3+JgZmzXXTkuHOk3wfGQFdNLat+ezMdkt8EU8j6N3TLZ/8UxNl+eKGsm/RJL4QKGpg3/Sfbza22XHERepIrMyFsQXqhnSwDZF2VT6XoRJuYI+nret0pn7Bcm22AFwz4OAv9R6fgRQ2w3m3g0bOZp/ea52fv+8UivNsyo/llbajqJAgCVdRz8Jm9fSg0A/falsVVkefEEgDQwGEElxQwJ9aSj1A/NUA40cqjIIPGhoVtA7/p+VklH88cA0pQ=='
      }
    end
    
    it 'parses and verifies the authentication response from bank' do
      Ipizza::Provider::Swedbank.new.authentication_response(@params).should be_valid
    end
  end
end
