class MarathonEndpoint
  include HTTPUtils
  include Utils

  def initialize(host, port=8080)
    @host = host
    @port = port
  end
  
  def app(app_name)
    raise ArgumentError, "Argument be a String" unless (app_name.class == String )
    to_j(get_response_with_redirect(@host, '/v2/apps/' + app_name, @port))[:app]
  end
  
  def all_apps
    to_j(get_response_with_redirect(@host, '/v2/apps/', @port))[:apps]
  end
  
  def app_names
    all_apps.collect { |a| a[:id][1..-1] }
  end
  
  def tasks_ids(app_name)
    app(app_name)[:tasks].collect { |t| t[:id] }
  end
  
  def my_tasks(hostname)
    raise ArgumentError, "missing hostname argument", caller if hostname.nil?
    app_names.collect { |n| app(n)[:tasks].select { |t| t[:host] =~ /^#{hostname}$/ }  }
  end
  
  def my_task_ids(hostname, framework = 'marathon')
    my_tasks(hostname).collect { |t| t.collect { |a| a[:id] } }.flatten
  end
  
  def task_ids
    app_names.collect { |a| tasks_ids(a) }
  end
  
end
