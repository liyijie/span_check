# encoding: utf-8
module SpanCheck
    class IemapParse
      def initialize row
        @ie_rule = row[1]
        @insidepara = row[2]
        @outsidepara = row[3]
      end

      def write_xml_element e
        e.ierule("equalrule" => @ie_rule, "insidepara" => @insidepara, 
                  "outsidepara" => @outsidepara)
      end
    end
end
