require 'json'
require 'net/http'
require 'uri'
require 'zlib'

module HTTPUtils

  def get_response_with_redirect(host, request_uri, port, user='', passwd='')
     begin
       retries ||= 0
       http = Net::HTTP::new(host, port)
       req = Net::HTTP.const_get('Get').new(request_uri)
       req.basic_auth user,passwd
       response = http.request(req)
     rescue Zlib::DataError, Zlib::BufError
       retry if (retries += 1) < 3
     rescue Exception => e
       raise e
     end

     if response.is_a?(Net::HTTPRedirection)
       begin
       redirect_uri = URI.parse(response.header['location'])
       return redirect_uri
       rescue SocketError => e
         raise e, "Error connecting to #{redirect_uri}: #{e.message}"
       end
     end     
     response
  end

  def to_j(response)
    if response.is_a? Net::HTTPResponse
      JSON.parse(response.body, :symbolize_names => true)
    elsif response.is_a? String
      JSON.parse(response, :symbolize_names => true)
    end 
  end
  
  def valid_url(url)
    if (url =~ /\A#{URI::regexp}\z/)
      return true
    end
    return false
  end
  
  def construct_uri(url)
    raise Error::BadURLError unless (valid_url(url))
    return URI.parse(url)
  end
  
end
