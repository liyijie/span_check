# encoding: utf-8
require "singleton"

module SpanCheck

  class IeconfigParse
    include Singleton
    attr_accessor :ieconfigs

    def initialize()
      @head = ()
      @ieconfigs = {}
      @filename = ""
    end

    def load(configfiles)
      @ielist = IelistParse.new("../sample/IEList.xml")
      load_old_ieconfig
      configfiles.each do |configfile|
        workbook = Spreadsheet::ParseExcel.parse(configfile)
        worksheet = workbook.worksheet(1)
        @head = SpanCheck::row_format worksheet.row(0)

        worksheet.each(1) do |raw_row|
          row = SpanCheck::row_format(raw_row)
          contentmap = {}
          @head.each_with_index do |key, i|
            contentmap[key] = row[i]
          end
          longname = contentmap["name"]
          shortname = @ielist.get_shortname longname
          if shortname.nil?
            shortname = @ielist.generate_ie_shortname(longname, to_list_map(contentmap))
          end
          contentmap["shortname"] = shortname
          @ieconfigs[contentmap["name"]] = contentmap
          @ielist.update(to_list_map(contentmap))
        end
      end
    end

    def parse  
      write_file(to_config_xml, "IEConfig.xml")
      write_file(to_list_xml(@ielist), "IEList.xml")
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
          contentmap[key] = value
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
        @ieconfigs.each do |key, value|
          shortname = value["shortname"]
          longname = value["name"]
          value.delete("shortname")
          value["name"] = shortname
          value["alias"] = longname
          e.EUnit(value)
        end
      end
    end

    def to_list_xml ielist
      ielist.to_list_xml
    end

    def to_log_xml
      xml_string = ""
      e = Builder::XmlMarkup.new(:target => xml_string, :indent => 2)
      e.instruct! :xml,:version =>'1.0',:encoding => 'utf-8'
      e.LogFormat("Version" => "10000") do
        
      end
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
