require 'json'
require 'net/http'
require 'uri'

module HTTPUtils

  def get_response_with_redirect(*args)
     response = Net::HTTP.get_response(*args)
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