# encoding: utf-8
# require 'spreadsheet'
require 'parseexcel'
require "parseexcel/parser"
require 'builder' 
# require "span_check/ie_exp_convert"

module SpanCheck
  autoload :AttrParse, "./span_check/attr_parse"
  autoload :IeExpConvert, "./span_check/ie_exp_convert"
  autoload :IemapParse, "./span_check/iemap_parse"
  autoload :IelistParse, "./span_check/ielist_parse"
  autoload :IeconfigParse, "./span_check/ieconfig_parse"

  def self.row_format row
    rlt = []
    row.each do |cell|
      content = cell.nil? ? "" : cell.to_s('utf-8')
      rlt << content
    end
    rlt
  end
end

# ieconvert = SpanCheck::IeExpConvert.new("../doc/LC_LTE_IE.xls")
# ieconvert.parse


ieconfig = SpanCheck::IeconfigParse.new("../doc/HISI_LTE_IEConfig.xls")
ieconfig.parse
