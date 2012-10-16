# encoding: utf-8
module SpanCheck::AttrParse
  class StringA < Base
    def write_xml_element e
      e.attr("name" => @name, "type" => attr_type) do
        type_int = SpanCheck::AttrParse::get_type_int @arraytype
        stringtype = "#{@arraytype.upcase}##{type_int}"
        if (@is_length_fix == "YES")
          e.stringdesc("is_length_fix" => @is_length_fix, "stringlength" => @arraylength, "stringtype" => stringtype)  
        else
          e.stringdesc("is_length_fix" => @is_length_fix, "relateattr" => @relateattr,"stringtype" => stringtype)  
        end
      end
    end

  end
end