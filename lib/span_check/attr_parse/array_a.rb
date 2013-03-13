# encoding: utf-8
module SpanCheck::AttrParse
  class ArrayA < Base
    def write_xml_element e
      e.attr("name" => @name, "type" => attr_type) do
        type_int = SpanCheck::AttrParse::get_type_int @arraytype
        e.arraydesc(
          "is_length_fix" => @is_length_fix,
          "relateattr" => @relateattr,
          "arraylength" => @arraylength,
          "arraytype" => "#{@arraytype.upcase}#{get_arraytype_str(type_int)}",
          "structname" => @structname)
      end
      if @structname.empty? && @arraytype.upcase == "STRUCT"
        Logger.instance.log "error struct: \"#{@name}\" structname can not be empty"
      end
    end

    def get_arraytype_str type_int
      type_str = ''
      if type_int != -1
        type_str = "##{@type_int}"
      end
      type_str
    end
  end
end