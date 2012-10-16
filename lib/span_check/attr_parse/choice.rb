# encoding: utf-8
module SpanCheck::AttrParse
  class Choice < Base
    def write_xml_element e
      e.attr("name" => @name, "type" => attr_type, 
            "relateattr" => @choiceattr)
    end
  end
end