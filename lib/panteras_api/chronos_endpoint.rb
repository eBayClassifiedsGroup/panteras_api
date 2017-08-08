class ChronosEndpoint
  include HTTPUtils
  include Utils

  def initialize(host, port=4400)
    @host = host
    @port = port
  end

  def all_apps
    begin
      to_j(get_response_with_redirect(@host, '/scheduler/jobs', @port))
    rescue Errno::ECONNREFUSED => e
      to_j('[]')
    end
  end

  def my_task_ids(hostname, framework = 'chronos')
    all_apps.collect { |a| a[:name][0..-1] }
  end

end
