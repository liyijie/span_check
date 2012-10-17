# encoding: utf-8
module SpanCheck
    class IemapParse
      def initialize row
        @ie_rule = row[1] || ""
        @insidepara = row[2] || ""
        @outsidepara = row[3] || ""
        replace_long_ie unless @ie_rule.empty?
      end

      def replace_long_ie
        ieconfig = SpanCheck::IeconfigParse.instance
        longie = @ie_rule.split(/\=|\[/)[0]  
        shortie = ieconfig.get_shortname(longie)
        if shortie
          @ie_rule = @ie_rule.sub(longie, shortie)
        else
          puts "error: short ie not found #{longie}"
        end
      end

      def write_xml_element e
        e.ierule("equalrule" => @ie_rule, "insidepara" => @insidepara, 
                  "outsidepara" => @outsidepara)
      end
    end
end
