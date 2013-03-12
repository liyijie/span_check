# encoding: utf-8
module SpanCheck::AttrParse
  class Subpacket < Base
    def write_xml_element e
      e.attr("name" => @name, "type" => @type.upcase, "subtype" => @len, "relateattr" => @relateattr)
    end
  end
end