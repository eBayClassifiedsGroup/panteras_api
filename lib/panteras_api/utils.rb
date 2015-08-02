require 'socket'

module Utils
  def self.hostname
    Socket.gethostname.strip
  end
  
  def self.fully_qualified_hostname
    begin
      Socket.gethostbyname(Socket.gethostname.strip).first
    rescue SocketError => e
      raise StandardError, "Could not get fully qualified domain name using gethostbyname."
    end
  end
  
  
end