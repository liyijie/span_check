# encoding: utf-8
module SpanCheck::AttrParse
  class Bit < Base
    def attr_type
      "#{@type.upcase}##{@len.to_i}"
    end
  end
end