# encoding: utf-8
require "singleton"

module SpanCheck

  class IeconfigParse
    include Singleton
    attr_accessor :ieconfigs

    def initialize()
      @head = ()
      @ieconfigs = {}
      @ieconfigs_short = {}
      @filename = ""
    end

    def load(configfiles)
      @ielist = IelistParse.new("../sample/IEList.xml")
      load_old_ieconfig

      @logparser = LogParse.new("../sample/LogFormat_100.xml")
      @logparser.load_old_log

      configfiles.each do |configfile|
        workbook = Spreadsheet::ParseExcel.parse(configfile)
        worksheet = workbook.worksheet(1)
        @head = SpanCheck::row_format worksheet.row(0)

        worksheet.each(1) do |raw_row|
          row = SpanCheck::row_format(raw_row)
          contentmap = {}
          @head.each_with_index do |key, i|
            contentmap[key] = row[i] unless key.empty?
          end
          longname = contentmap["name"]
          next if longname.empty?
          shortname = @ielist.get_shortname longname
          if shortname.nil?
            shortname = @ielist.generate_ie_shortname(longname, to_list_map(contentmap))
          end
          contentmap["shortname"] = shortname
          @ieconfigs[contentmap["name"]] = contentmap
          @ielist.update(to_list_map(contentmap))

          is_group = contentmap["paramcount1"].to_i > 0
          @logparser.update_logitem shortname, is_group
        end
      end
    end

    def parse
      @ieconfigs_short = {}
      @ieconfigs.each do |longname, info|
        shortname = info["shortname"]
        @ieconfigs_short[shortname] = info
      end

      write_file(to_config_xml, "IEConfig.xml")
      write_file(to_list_xml(@ielist), "IEList.xml")
      write_file(to_log_xml, "LogFormat_100.xml")
      write_file(to_sql_config, "TableIEsConfig.ini")
    end

    def get_shortname longname
      @ieconfigs.has_key?(longname) ? @ieconfigs[longname]["shortname"] : nil
    end

    def load_old_ieconfig
      doc = Nokogiri::XML(open("../sample/IEConfig.xml"))
      @ieconfigs = {}
      doc.search("EUnit").each do |ie|
        contentmap = {}
        ie.each do |key, value|
          contentmap[key] = value unless key.empty?
        end
        shortname = contentmap["name"]
        longname = @ielist.get_longname(shortname)
        #如果找不到就抛弃了，等待文档重新成生这些内容
        if longname
          contentmap["name"] = longname
          contentmap["shortname"] = shortname
          @ieconfigs[longname] = contentmap
        end
      end
    end

    def to_list_map ieconfig

      ielistmap = {}
      ielistmap["Count1"] = ieconfig["paramcount1"].to_i
      ielistmap["Count2"] = ieconfig["paramcount2"].to_i
      ielistmap["Name"] = ieconfig["name"]
      ielistmap
    end

    def exist? key
      @ieconfigs.has_key? key
    end

    def to_config_xml
      xml_string = ""
      e = Builder::XmlMarkup.new(:target => xml_string, :indent => 2)
      e.instruct! :xml,:version =>'1.0',:encoding => 'utf-8'
      e.List do
        @ieconfigs.each do |key, content|
          value = content.dup
          shortname = value["shortname"]
          longname = value["name"]
          value.delete("shortname")
          value["name"] = shortname
          value["alias"] = longname
          content["alias"] = longname
          e.EUnit(value)
        end
      end
    end

    def to_list_xml ielist
      ielist.to_list_xml
    end

    def to_log_xml
      @logparser.to_log_xml @ieconfigs_short
    end

    def to_sql_config
      @logparser.to_sql_config      
    end

    def write_file xml_string, filename
      d = Time.now
      date_folder = "./#{d.year}.#{d.mon}.#{d.day}";
      Dir.mkdir("#{date_folder}") unless File.exist?("#{date_folder}")
       
      File.open("#{date_folder}/#{filename}", "w") do |file|
        file.puts xml_string
      end
    end
  end
end
