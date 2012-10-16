# encoding: utf-8
module SpanCheck::AttrParse
  class Base
    def initialize(row, type_int)
      @type_int = type_int
      @name = row[1] || ""
      @type = row[2] || ""
      @len = row[3] || ""
      @extend = row[4] || ""
      @is_length_fix = row[5] || ""
      @relateattr = row[6] || ""
      @arraylength = row[7] || ""
      @arraytype = row[8] || ""
      @structname = row[9] || ""
      @bitrelatedetailinfo = row[10] || ""
      @choiceattr = row[11] || ""
    end

    def attr_type
      "#{@type.upcase}##{@type_int}"
    end

    def write_xml_element e
      e.attr("name" => @name, "type" => attr_type, "extend" => @extend)
    end
  end
end