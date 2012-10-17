# encoding: utf-8
module SpanCheck
  class IeExpConvert

    class StructParse
      def initialize(struct_name)
        @struct_name = struct_name
        @msgparse = nil
        @recent_struct = nil
        @attrs = []
      end

      def << attr_parse
        @attrs << attr_parse
      end

      def write_xml_element e
        e.struct("name" => @struct_name) do
          @attrs.each do |attr_parse|
            attr_parse.write_xml_element e
          end
        end
      end
    end

    class MsgParse
      attr_accessor :msgname
      def initialize(msginfo)
        infos = msginfo.split(/\(|\)/)
        @msgname = infos[0]
        @msgid = infos[1]
        @structs = []
        @ie_rules = []
      end

      def add_struct struct_parse
        @structs << struct_parse
      end

      def add_ie_rule ie_rule
        @ie_rules << ie_rule
      end

      def write_xml_element e
        e.msg("id" => @msgid, "msgname" => @msgname) do
          e.msgbody("skip_length" => "", "msg_length" => "") do
            @structs.each do |struct_parse|
              struct_parse.write_xml_element e
            end
          end
          e.iemap do
            @ie_rules.each do |ie_rule|
              ie_rule.write_xml_element e
            end
          end
        end
      end
    end

    IEMAP_KEY = "IEMap"
    def initialize(xml_file)
      @xml_file = xml_file
    end

    def parse
      # Spreadsheet.client_encoding = "UTF-8"
      xml_string = ""
      e = Builder::XmlMarkup.new(:target => xml_string, :indent => 2)
      e.instruct! :xml,:version =>'1.0',:encoding => 'utf-8'

      workbook = Spreadsheet::ParseExcel.parse(@xml_file)
      sheet_count = workbook.sheet_count
      e.all do
        (0..sheet_count-1).each do |count|
          worksheet = workbook.worksheet count
          skip = 1
          struct_name = ""
          step = 1;

          worksheet.each(skip) do |raw_row|
            next if raw_row.nil?
            row = SpanCheck::row_format raw_row
            keyname = row[0]
            if keyname == IEMAP_KEY
              step = 2
            elsif !keyname.empty?
              struct_name = keyname
              if (struct_name =~ /\(/)
                @msgparse = MsgParse.new(struct_name)
                struct_parse = StructParse.new(@msgparse.msgname)
              else
                struct_parse = StructParse.new(struct_name)
              end
              @recent_struct = struct_parse
              @msgparse.add_struct struct_parse unless @msgparse.nil?
            else
              #strcut
              if step == 1
                next if row[2].nil?
                attr_parse = AttrParse.create(row)
                @recent_struct << attr_parse
              #IEMap
              elsif step == 2
                ie_rule = IemapParse.new(row)
                @msgparse.add_ie_rule ie_rule unless @msgparse.nil?
              end
            end
          end
            @msgparse.write_xml_element e
          end

          File.open("IE.xml", "w") do |f|
            f.puts xml_string
          end
        end
      end
    end
  end