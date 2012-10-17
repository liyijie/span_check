require "nokogiri"

module SpanCheck
  class IelistParse
    def initialize(xmlfile)
      @longname_map = {}
      @shortname_map = {}
      @max = 0
      doc = Nokogiri::XML(open(xmlfile))
      doc.search("IEs").each do |ie|
        shortname = ie.get_attribute("Id")
        ie_id = shortname.gsub('i', '').to_i
        if (ie_id > @max)
          @max = ie_id
        end
        longname = ie.get_attribute("Name")
        count1 = ie.get_attribute("Count1")
        count2 = ie.get_attribute("Count2")
        contentmap = {}
        contentmap["Count1"] = count1
        contentmap["Count2"] = count2
        contentmap["Id"] = shortname
        contentmap["Name"] = longname
        @longname_map[longname] = contentmap
        @shortname_map[shortname] = longname
      end
    end

    def get_shortname(longname)
      @longname_map[longname]["Id"]
    end

    def get_longname(shortname)
      @shortname_map[shortname]
    end

    def generate_ie_shortname longname, ieinfo_map
      @max += 1
      shortname = "i#{@max}"
      contentmap = ieinfo_map.dup
      contentmap["Id"] = shortname
      @longname_map[longname] = contentmap
      @shortname_map[shortname] = longname
    end

    def update(ieinfo_map)
      longname = ieinfo_map["Name"]
      if @longname_map.has_key? longname
        @longname_map[longname]["Count1"] = ieinfo_map["Count1"]
        @longname_map[longname]["Count2"] = ieinfo_map["Count2"]
      end
      
    end

    def to_list_xml
      xml_string = ""
      e = Builder::XmlMarkup.new(:target => xml_string, :indent => 2)
      e.instruct! :xml,:version =>'1.0',:encoding => 'utf-8'
      e.IE_LIST do
        @longname_map.each_value do |value|
          e.IEs(value)
        end
      end
    end

  end
end
