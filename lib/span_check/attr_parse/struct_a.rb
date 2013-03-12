# encoding: utf-8
module SpanCheck::AttrParse
  class StructA < Base
    def write_xml_element e
      if @structname.empty?
        Logger.instance.log "error struct: \"#{@name}\" structname can not be empty"
      end
      if @bitrelatedetailinfo.empty?
        e.attr("name" => @name, "type" => attr_type, "structname" =>@structname)
      else
        bitrelateattr = @bitrelatedetailinfo.split(/\(|,/)[1] unless @bitrelatedetailinfo.empty?
        e.attr("name" => @name, "type" => attr_type, "structname" =>@structname,  
          "bitrelateattr" => bitrelateattr, "bitrelatedetailinfo" => @bitrelatedetailinfo)     
      end
    end
  end
end