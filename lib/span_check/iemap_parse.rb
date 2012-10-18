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
        longie = @ie_rule.split(/\=|\[|\{/)[0]  
        shortie = ieconfig.get_shortname(longie)
        unless (longie =~ /^GSM/i || longie =~ /^TDSCDMA/i || longie =~ /^TDDLTE/i)
          Logger.instance.log "error 1: \"#{longie}\" must start with GSM, TDSCDMA, TDDLTE"
        end
        if shortie
          @ie_rule = @ie_rule.sub(longie, shortie)
        else
          Logger.instance.log "error 2: \"#{longie}\" can not found in ieconfig"
        end
      end

      def write_xml_element e
        e.ierule("equalrule" => @ie_rule, "insidepara" => @insidepara, 
                  "outsidepara" => @outsidepara)
      end
    end
end
