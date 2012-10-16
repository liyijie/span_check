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
      end

      def << struct_parse
        @structs << struct_parse
      end

      def write_xml_element e
        e.msg("id" => @msgid, "msgname" => @msgname) do
          e.msgbody("skip_length" => "", "msg_length" => "") do
            @structs.each do |struct_parse|
              struct_parse.write_xml_element e
            end
          end
        end
      end
    end

    IEMAP_KEY = "IEMap"
    def initialize(xml_file)
      @xml_file = xml_file
    end

    def row_format row
      rlt = []
      row.each do |cell|
        content = cell.nil? ? "" : cell.to_s('utf-8')
        rlt << content
      end
      rlt
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

          worksheet.each(skip) do |row|
            next if row.nil?
            row = row_format row
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
              @msgparse << struct_parse unless @msgparse.nil?
            else
                #数据
                if step == 1
                  attr_parse = AttrParse.create(row)
                  @recent_struct << attr_parse
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