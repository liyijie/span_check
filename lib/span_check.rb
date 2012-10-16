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
end

ieconvert = SpanCheck::IeExpConvert.new("../doc/LC_LTE_IE.xls")
ieconvert.parse