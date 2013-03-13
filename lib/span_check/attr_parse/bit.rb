# encoding: utf-8
module SpanCheck::AttrParse
  class Bit < Base
    def attr_type
      len_str = ''
      if @len =~ /i/
        len_str = @len.to_s
      else
        len_str = @len.to_i
      end
      "#{@type.upcase}##{len_str}"
    end
  end
end