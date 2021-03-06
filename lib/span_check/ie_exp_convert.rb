# encoding: utf-8

require "roo"

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
        @msgid = infos[1].downcase
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
          if (@msgname =~ / /)
            Logger.instance.log "error 3: \"#{@msgname}\" should not has white space in stuct name"
          end
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

    IEMAP_KEY = "IEMAP"
    def initialize(xml_files)
      @xml_files = xml_files
    end

    def parse
      tempstring = ""
      e = Builder::XmlMarkup.new(:target => tempstring, :indent => 2)
      e.instruct! :xml,:version =>'1.0',:encoding => 'utf-8'
      e.all do
        @xml_files.each do |xml_file|
          workbook = Roo::Spreadsheet.open(xml_file)

          worksheets = workbook.sheets
          sheet_count = workbook.sheets.size
          (0..sheet_count-2).each do |count|
            worksheet = workbook.sheet count

            skip = 1
            struct_name = ""
            step = 1;

            (2..worksheet.last_row).each do |row_index|
              raw_row = worksheet.row(row_index)
              next if raw_row.nil?
              row = SpanCheck::row_format raw_row
              keyname = row[0]
              if keyname.upcase == IEMAP_KEY
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
              end
              #strcut
              if step == 1
                next if row[2].nil? || row[2].empty?
                if (xml_file =~ /LTE/i)
                  row[2] = AttrParse.convert_reverse row[2]
                  row[8] = AttrParse.convert_reverse row[8]
                end
                attr_parse = AttrParse.create(row)
                @recent_struct << attr_parse
              #IEMap
              elsif step == 2
                next if row[1].nil? || row[1].empty?
                ie_rule = IemapParse.new(row)
                @msgparse.add_ie_rule ie_rule unless @msgparse.nil?
              end
            end 
            @msgparse.write_xml_element e
          end
        end
      end
      filename = ""
      @xml_files.each do |file|
        file = file.split('/')[-1].sub('.xls','')
        if filename.empty?
          filename = file
        else
          filename = "#{filename}&#{file}"
        end
      end
      SpanCheck::IeconfigParse.instance.write_file tempstring, "#{filename}.xml"
    end
  end
end