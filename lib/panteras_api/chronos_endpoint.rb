class ChronosEndpoint
  include HTTPUtils
  include Utils

  def initialize(host, port=8080)
    @host = host
    @port = port
  end

  def all_apps
    to_j(get_response_with_redirect(@host, '/scheduler/jobs', @port))
  end

  def my_task_ids(hostname, framework = 'chronos')
    all_apps.collect { |a| a[:name][0..-1] }
  end

end
