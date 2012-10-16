# encoding: utf-8
module SpanCheck
  module AttrParse
    autoload :Base, "./span_check/attr_parse/base"
    autoload :U8, "./span_check/attr_parse/u8"
    autoload :Int16, "./span_check/attr_parse/int16"
    autoload :Int16_R, "./span_check/attr_parse/int16_r"
    autoload :U16, "./span_check/attr_parse/u16"
    autoload :U16_R, "./span_check/attr_parse/u16_r"
    autoload :Int32, "./span_check/attr_parse/int32"
    autoload :Int8, "./span_check/attr_parse/int8"
    autoload :U32, "./span_check/attr_parse/u32"
    autoload :StringA, "./span_check/attr_parse/string_a"
    autoload :StructA, "./span_check/attr_parse/struct_a"
    autoload :ArrayA, "./span_check/attr_parse/array_a"
    autoload :Choice, "./span_check/attr_parse/choice"

    def self.create(row)
      name = row[1]
      type = row[2]
      attr_parse = Base.new(row, 0)
      if type == 'uint8'
        type_int = 1
        attr_parse = U8.new(row, type_int)
      elsif type == 'int16'
          type_int = 2
          attr_parse = Int16.new(row, type_int)
      elsif type == 'int16_reverse'
           type_int = 3
           attr_parse = Int16_R.new(row, type_int)   
      elsif (type == 'uint16')
        type_int = 4
        attr_parse = U16.new(row, type_int)
      elsif type == 'uint16_reverse'
        type_int = 5
        attr_parse = U16_R.new(row, type_int)
      elsif type == 'int32'
        type_int = 6
        attr_parse = Int32.new(row, type_int)
      elsif type == 'int8'
        type_int = 7
        attr_parse = Int8.new row, type_int
      elsif type == 'uint32'
        type_int = 8
        attr_parse = U32.new row, type_int
      elsif type == 'uint32_reverse'
        type_int = 9
        attr_parse = U32_R.new row, type_int
      elsif type == 'string'
        type_int = 10
        attr_parse = StringA.new row, type_int
      elsif type == 'struct'
        type_int = 11
        attr_parse = StructA.new row, type_int
      elsif type == 'array'
        type_int = 12
        attr_parse = ArrayA.new row, type_int
      elsif type == 'choice'
        type_int = 13
        attr_parse = Choice.new row, type_int
      end
      attr_parse
    end
  end
end