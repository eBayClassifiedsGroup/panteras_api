require 'open3'

class DockerHost
  extend HTTPUtils
  
  def self.ps
    self.command("docker ps")[:output]
  end
  
  def self.running_containers
    output = self.command("docker ps")[:output]
    raise MesosConsulCommandError, "Command 'docker ps' did not return an array of strings" if (output.class != Array || output.length == 0)
    
    result = output.map.with_index do |line, i|
      next if i == 0 
      container_id, image, *center, name = line.split
      { container_id:  container_id, name: name, image: image }       
    end
    
    return result.compact
  end
  
  def self.inspect(*keys)
    containers = self.running_containers
    containers.map do |c|
      inspect = self.command("docker inspect #{c[:container_id]}")[:output]
      h = to_j(inspect.join).first    
      task_id = h[:Config][:Env].select { |env| env.upcase  =~ /MESOS_TASK_ID=/ }.first
      mesos_task_id = task_id.nil? ? '' : task_id.split(/=/)[1] 
      { id: h[:Id], image: h[:Image], name: h[:Name][1..-1], mesos_task_id: mesos_task_id, chronos_job: h[:Config][:Env].join(',').include?('CHRONOS_JOB_NAME=') ? true : false  }
    end
  end
  
  def self.inspect_partial
    self.inspect
  end
  
  private
  
  class MesosConsulCommandError < StandardError ; end
  
  def self.command(command)
    output = []
    error = []
    begin
      Open3.popen3(command) do |stdin, stdout, stderr, wait_thr|
        
        exit_status = wait_thr.value
        
        unless exit_status.success?
          $stderr.puts stderr.readlines
          raise MesosConsulCommandError, "Command '#{command}' returned status #{exit_status.exitstatus}"          
        end
        
        while line = stderr.gets
          $stderr.puts line
          if line.strip.length > 0
            error << line.strip
          end
        end
        
        while line = stdout.gets
         if line.strip.length > 0          
           output << line.strip
         end
        end     
      
      end
      
    rescue Errno::ENOENT => e
      raise MesosConsulCommandError, "Error while running command #{command}: #{e.message}"
    end
      
    return { :output => output, :error => error}
       
  end
end
