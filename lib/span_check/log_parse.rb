# encoding: utf-8
module SpanCheck
  class LogParse
    def initialize(logfile)
      @logfile = logfile
      @logline_map = {}
      @logitem_map = {}
      @recentindex = 0;
      @recentindex_count = 0;
      @maxindex = 0
    end

    def load_old_log
      doc = Nokogiri::XML(open("../sample/LogFormat_100.xml"))
      @logline_map = {}
      @maxindex = 0
      doc.search("LogLine").each do |logline|
        logline_index = logline.get_attribute("Index").to_i
        logline_name = logline.get_attribute("Name")
        @logline_map[logline_index] = logline_name
        @maxindex = logline_index if logline_index > @maxindex
        logline.search("LogItem").each do |logitem|
          logitem_name = logitem.get_attribute("Name").split('_')[0]
          @logitem_map[logitem_name] = logline_index
        end
      end
    end

    def update_logitem shortie_name, is_gourp
      unless @logitem_map.has_key? shortie_name
        logline_index = 0
        if is_gourp
          @maxindex += 1
          logline_index = @maxindex
        else
          if @recentindex_count > 9
            @maxindex += 1
            @recentindex = @maxindex
          end
          logline_index = @recentindex
        end
        @logitem_map[shortie_name] = logline_index
        @logline_map[logline_index] = logline_index
      end
    end

    def to_log_xml ieconfigs_short
      line_items_map = {}
      @logitem_map.each do |item_name, line_index|
        line_items_map[line_index] ||= []
        line_items_map[line_index] << item_name
      end

      xml_string = ""
      e = Builder::XmlMarkup.new(:target => xml_string, :indent => 2)
      e.instruct! :xml,:version =>'1.0',:encoding => 'utf-8'
      e.LogFormat("Version" => "10000") do
        @logline_map.each do |line_index, line_name|
          e.LogLine("Name" => line_name, "line_index" => line_index) do
            items = line_items_map[line_index]
            items ||= []
            items.each do |item|
              info = ieconfigs_short[item]
              if info.nil?
                type = "double"
                if (item == "msg" || item == "Event" || item == "Signals")
                  type = "string"
                end
                e.LogLine("Name" => item, "Type" => type)
              else
                count1 = info["paramcount1"].to_i
                count2 = info["paramcount2"].to_i
                if (count1 > 0)
                  @item_map = {}
                  name = item
                  aliasname = info["alias"]
                  (0..count1-1).each do |x|
                    name_x = "#{name}_#{x}"
                    aliasname_x = "#{aliasname}_#{x}"
                    if (count2 > 0)
                      (0..count2-1).each do |y|
                        name_y = "#{name}_#{y}"
                        aliasname_y = "#{aliasname}_#{y}"
                        @item_map[name_y] = aliasname_y
                      end
                    else
                      @item_map[name_x] = aliasname_x
                    end
                  end
                  @item_map.each do |name, aliasname|
                    e.LogLine("Name" => name, "Type" => "double", "Alias" => aliasname)  
                  end
                else
                  e.LogLine("Name" => item, "Type" => "double", "Alias" => info["name"])
                end
              end
            end
          end
        end
      end
    end

  end
end

