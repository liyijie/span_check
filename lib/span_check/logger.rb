# encoding: utf-8
require "singleton"

module SpanCheck
  class Logger
    include Singleton

    def initialize
      @logstrings = []
    end

    def log logstring
      @logstrings << logstring
    end

    def flush
      filename = "result.log"
      d = Time.now
      date_folder = "./#{d.year}.#{d.mon}.#{d.day}";
      Dir.mkdir("#{date_folder}") unless File.exist?("#{date_folder}")
       
      File.open("#{date_folder}/#{filename}", "w") do |file|
        file.puts @logstrings
      end
    end
  end

end