# encoding: utf-8
module SpanCheck::AttrParse
  class StructA < Base
    def write_xml_element e
      if @bitrelatedetailinfo.empty?
        e.attr("name" => @name, "type" => attr_type, "strcutname" =>@structname)
      else
        bitrelateattr = @bitrelatedetailinfo.split(/\(|,/)[1] unless @bitrelatedetailinfo.empty?
        e.attr("name" => @name, "type" => attr_type, "strcutname" =>@structname,  
          "bitrelateattr" => bitrelateattr, "bitrelatedetailinfo" => @bitrelatedetailinfo)     
      end
    end
  end
end