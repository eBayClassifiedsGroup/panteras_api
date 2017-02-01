require 'open3'

class DockerHost
  extend HTTPUtils

  def self.ps
    output = self.command("docker ps")[:output]
    raise MesosConsulCommandError, "Command 'docker ps' did not return an array of strings" if (output.class != Array || output.length == 0)
    return output
  end

  def self.running_containers
    output = self.ps
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
      stdout, stderr, status = Open3.capture3(command)
    rescue Errno::ENOENT => e
      raise MesosConsulCommandError, "Error while running command #{command}: #{e.message}"
    end
    return { :output => stdout.split(/\n+/), :error => stderr.split(/\n+/)}
  end

end
