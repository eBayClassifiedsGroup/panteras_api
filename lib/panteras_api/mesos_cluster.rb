#!/usr/bin/env ruby

require 'uri'
require 'json'

class MesosCluster
  include HTTPUtils
  include Utils
  
  attr_reader :state
  
  def initialize(host, port=5050)
    @protocol = "http:"
    @host = host
    @port = port
    @master_info = "/master/redirect"
    @state_info = "/state.json"
    @state = parse_state
  end

  def parse_state
    response = get_response_with_redirect(@host, @master_info, @port).to_s
    response = @protocol + response if !response.include?@protocol
    redirect_response = response
    if URI.parse(redirect_response).kind_of?(URI::HTTP)
      if ! valid_url(redirect_response.to_s)
        raise StandardError, "Response from #{@protocol}//#{@host}:#{@port}#{@master_info} is not a valid url: #{redirect_response.to_s}"
      end      
      return to_j(get_response_with_redirect(URI.join(redirect_response.to_s, @state_info)))
    end
  
  end
  
  def master_hostname
    state[:hostname]    
  end
  
  def master_id
    state[:id]
  end
  
  def frameworks
    state[:frameworks]
  end
  
  def tasks_completed
    state[:frameworks].collect { |f| f[:completed_tasks].collect { |t| t  } }   
  end
  
  def tasks
    results = frameworks.collect { |f| f[:tasks].collect { |t| t[:slave_hostname] = slave_hostname_by_id(t[:slave_id]) ; t } }
    results.reject { |r| r.nil? or r.length == 0 }.first
  end
  
  def task_ids
    tasks.collect { |t| t[:id] }
  end
  
  def my_tasks_ids(hostname)
   raise ArgumentError, "missing hostname argument", caller if hostname.nil?
   tasks.select { |t| t[:slave_hostname] =~ /^#{hostname}$/ }.collect { |t| t[:id] }
  end
  
  def resources
    state[:frameworks].collect { |f| f[:used_resources] }
  end
  
  def slave_hostname_by_id(id)
    slaves.select { |s| s[:id] == id }.first[:hostname]
  end
  
  def slaves
    state[:slaves].collect do |s|
      s.select { |k,v|  [:hostname, :id].include?(k)}
    end
  end
  
  def to_s
    JSON.pretty_generate @state
  end
  
end
