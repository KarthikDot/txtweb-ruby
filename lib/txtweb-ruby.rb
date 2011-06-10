#Version 0.1.0

class NilClass
  def blank?
    true
  end unless nil.respond_to? :blank?
end

class String
  def blank?
    self !~ /\S/
  end unless "".respond_to? :blank?
end


module TxtWeb
  VERSION = '0.1.0'
  class TxtWebRuby
    def initialize(opts)
      @api_url = opts[:api_url] || 'http://api.txtweb.com/v1/push'
      @api_params = {}
      @api_params[:txtweb_pubkey] = opts[:txtweb_pubkey]
      
      raise "Invalid credentials" if opts[:txtweb_pubkey].blank?
    end
    
    def call_api(opts = {})
      res = Net::HTTP.post_form(
        URI.parse(@api_url),
        @api_params.merge(opts)
      )
      
      resp = XmlSimple.xml_in(res.body)      
      status = resp['status'][0]
      
      puts "TxtWeb Response: #{resp}"
      
      case res
        when Net::HTTPSuccess
          if status['code'] == 0
            return true, nil
          puts "API Call Failed : #{status['code']}"
          return false,nil   
        else
          return false, "HTTP Error : #{res}"
      end
      
    end

    def send_message(opts)
      msg = opts[:msg]
      number = opts[:txtweb_mobile]
      
      return false, 'Message should be less than 725 characters long' if msg.to_s.length > 724
      call_api(opts)
    end

  end
end
