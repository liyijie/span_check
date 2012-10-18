# encoding: utf-8
# require 'spreadsheet'
require 'parseexcel'
require "parseexcel/parser"
require 'builder' 
require "nokogiri"

# require "span_check/ie_exp_convert"

module SpanCheck
  autoload :AttrParse, "./span_check/attr_parse"
  autoload :IeExpConvert, "./span_check/ie_exp_convert"
  autoload :IemapParse, "./span_check/iemap_parse"
  autoload :IelistParse, "./span_check/ielist_parse"
  autoload :IeconfigParse, "./span_check/ieconfig_parse"
  autoload :LogParse, "./span_check/log_parse"

  def self.row_format row
    rlt = []
    row.each do |cell|
      content = cell.nil? ? "" : cell.to_s('utf-8')
      rlt << content
    end
    
    rlt
  end

  #遍历文件夹下指定类型的文件
  def self.list_files(file_path, file_type)
    files = []
    if (File.directory? file_path)
      Dir.foreach(file_path) do |file|
        if file=~/.#{file_type}$/
          files << "#{file_path}/#{file}"
        end
      end
    end 
    files
  end

end

ieconfig_files = SpanCheck::list_files("../doc/ieconfig", "xls")
ieconfig = SpanCheck::IeconfigParse.instance
ieconfig.load(ieconfig_files)
ieconfig.parse

iemap_files = SpanCheck::list_files("../doc/iemap", "xls")
puts "processing #{iemap_files} ......"
ieconvert = SpanCheck::IeExpConvert.new(iemap_files)
ieconvert.parse

# logparse = SpanCheck::LogParse.new("../sample/LogFormat_100.xml")
# logparse.load_old_log