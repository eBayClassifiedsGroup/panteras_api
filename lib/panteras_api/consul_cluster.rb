class ConsulCluster
  include HTTPUtils
  include Utils

  def initialize(host,port=8500)
    @host = host
    @port = port
    @datacenters = datacenters
    @dc = ""
    @hostname = Utils.hostname
  end
  
  def dc=(datacenter)
    raise ArgumentError, "#{datacenter} is not a valid datacenter" unless (@datacenters.include? datacenter)
    @dc = datacenter
  end
  
  def datacenters
    to_j(get_response_with_redirect(@host, '/v1/catalog/datacenters', @port))
  end
    
  def services
    service_names.collect { |s| service s.to_s }
  end
  
  def service_names
    services = to_j(get_response_with_redirect(@host, '/v1/catalog/services?dc=' + @dc, @port)).keys
    # exclude the consul and other PanteraS related services
    services.reject { |s| s.to_s == "consul" or s.to_s == "consul-ui" or s.to_s == "marathon" or s.to_s == "mesos" }
  end
  
  def my_services(hostname=@hostname)
    raise ArgumentError, "missing hostname argument", caller if hostname.nil?
    services.collect { |s| s.select { |i| i[:Node] =~ /^#{hostname}$/ } }.flatten
  end
  
  def my_service_ids
     my_services.collect { |s| s[:ServiceID].split(/:/)[1] }.compact
  end
  
  def service(service)
    to_j(get_response_with_redirect(@host, '/v1/catalog/service/' + service + '?dc=' + @dc, @port))
  end
  
end
