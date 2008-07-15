require 'json'
module OFC2
  module OWJSON
    def to_hash
      self.instance_values
    end
    alias :to_h :to_hash
    def to_json
      to_hash.to_json
    end
  end
  def self.included(controller)
    controller.helper_method(:ofc2)
  end
  def ofc2(width, height, url, base='/', id = '')
    out = []
    obj_id = 'chart'
    div_name = 'flashcontent'
    obj_id   += id
    div_name += id
    out << '<div id="' + div_name.to_s + '"></div>'
    out << '<script type="text/javascript">'
    out << 'swfobject.embedSWF('
    out << '"' + base.to_s + 'open-flash-chart.swf", "' + div_name.to_s + '",'
    out << '"' + width.to_s + '", "' + height.to_s + '", "9.0.0", "expressInstall.swf",'
    out << '{"data-file":"' + base.to_s + url.to_s + '"} );'
    out << '</script>'
    return out.join("\n")
  end
  
  class Element
    include OWJSON
    def initialize(text = '', css = "{font-size: 20px; color: #FF0F0F; text-align: center;}")
      set_text(text)
      set_style(css)
    end
    %w(style text).each do |method| 
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
    end
  end
  class XLegend <  Element 
  end
  class Title < Element 
  end
  class YLegend <  Element  
  end



  # y_axis
  class YAxisBase
    include OWJSON
    %w(stroke tick_length colour min max steps labels).each do |method| 
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
    end
	
    def set_colours( colour, grid_colour )
      set_colour( colour )
      set_grid_colour( grid_colour )
    end
    alias_method :colours=, :set_colours
	
    def set_range( min, max, steps=1 )
      set_min(min)
      set_max(max)
      set_steps( steps )
    end
    alias_method :range=, :set_range
	
    def set_offset( off )
      @offset = off ? 1 : 0
    end
    alias_method :offset=, :set_offset
  end

  class YAxis < YAxisBase
    # left axis control grid colour, but right not
    def set_grid_colour(color = '#ff0000')
      @grid__colour = color
    end
    alias_method :grid_colour=, :set_grid_colour
  end	

  class YAxisRight < YAxisBase 
  end

  # x_axis
  class XAxis 
    include OWJSON
    %w(stroke tick_length colour tick_height grid_colour min max steps labels offset).each do |method| 
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
    end
    %w(3d).each do |method| 
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@___#{method}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@___#{method}", a)
      end
    end
	
    def set_colours( colour, grid_colour )
      set_colour( colour )
      set_grid_colour( grid_colour )
    end
	
    # o is treat as a logic
    def set_offset( o )
      @offset = o ? true : false
    end
    
    def to_hash
      self.instance_values
    end
    alias :to_h :to_hash
    
    def to_json
      to_hash.to_json
    end
    
    # helper def to make the examples
    # simpler.
    #
    def set_labels_from_array( a )
      x_axis_labels = XAxisLabels.new
      x_axis_labels.set_labels( a )
      x_axis_labels.set_steps( @steps ) if @steps
      
      @labels = x_axis_labels
    end	
    alias_method :labels_from_array=, :set_labels_from_array
    def set_range( min, max )
      set_min(min)
      set_max(max)
    end
  end
  
  class XAxisLabel
    include OWJSON
    def initialize( text, colour, size, rotate, visible )
      set_text( text )
      set_colour( colour )
      set_size( size )
      set_rotate( rotate )
      set_visible( visible )
    end
	
    %w(text colour size rotate visible).each do |method| 
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
    end
	
    def set_vertical
      @rotate = "vertical"
    end
    alias_method :vertical, :set_vertical
	
  end
  class XAxisLabels
    include OWJSON
    %w(steps labels colour size).each do |method| 
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method}", a)
      end
    end
	
    def set_vertical()
      @rotate = "vertical"
    end
  end

  #scatter
  class ScatterValue
    include OWJSON
    def initialize( x, y, dot_size=-1 )
      @x = x
      @y = y
      set_dot_size(dot_size) if dot_size > 0
    end
    %w(x dot_size y).each do |method| 
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
    end
  end

  class Scatter
    include OWJSON
    def initialize( colour, dot_size )
      @type      = "scatter"
      set_colour( colour )
      set_dot_size( dot_size )
    end
  
    %w(colour dot_size values).each do |method| 
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
    end
  end

  
  class Graph
    include OWJSON
    
    %w(title x_axis y_axis y_axis_right x_legend y_legend bg_colour elements).each do |method| 
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method}", a)
      end
    end
    
    def initialize  
      @title = Title.new( "Graph" )
      @elements = []
    end

    def add_element( e )
      @elements << e
    end
    alias_method :<<, :add_element
    def render
      s = to_json
      s = s.gsub('___','')
      s.gsub('__','-')
    end
  end


  # line chart
  class LineBase 
    include OWJSON
    
    def initialize(text = 'label text', font_size='10px', values = [9,6,7,9,5,7,6,9,7])
      @type      = "line_dot"
      @text      = text
      @font__size = font_size
      @values    = values
    end
    %w(values width colour font_size dot_size halo_size text).each do |method| 
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
    end
  end
  class LineDot < LineBase
  end
  class Line < LineBase
    def initialize
      super
      @type      = "line"
    end
  end
  class LineHollow < LineBase
    def initialize
      super
      @type      = "line_hollow"
    end
  end
  
  
  #area
  class AreaHollow
    include OWJSON
    def initialize(fill_alpha = 0.35, values = [])
      @type      = "area_hollow"
      set_fill_alpha  fill_alpha
      @values    = values
    end
    %w(width color values dot_size text font_size fill_alpha).each do |method| 
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
    end
  end
  
  #bar
    
  class BarBase
    include OWJSON
    def initialize (values = [], text = '', size = '10px')
      @values = values
      @text = text
      @font__size = size
    end
    def set_key( text, size )
      @text = text
      @font__size = size
    end
    %w(alpha colour values text font_size).each do |method| 
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
    end
    def append_value( v )
      @values << v		
    end
    alias_method :<<, :append_value
  end
  class Bar < BarBase
    def initialize
      @type      = "bar"
    end
  end
  class Value
    include OWJSON
    def initialize(top = 0, color = '', tip = nil)
      @top = top
      @color = color
      @tip = tip
    end	
    def set_top( top )
      @top = top
    end	
    def set_colour( colour )
      @colour = colour
    end
	
    def set_tooltip( tip )
      @tip = tip
    end
  end
  class Bar3d < BarBase
    def initialize()
      @type      = "bar_3d"
    end
  end
  
  class BarGlass < BarBase
    def initialize()
      @type      = "bar_glass"
    end
  end

  
  class BarSketch < BarBase
    def initialize( colour = '#ff0000', outline_colour = '#00FF00', fun_factor = 5)
      @type      = "bar_sketch"
      set_colour( colour )
      set_outline_colour( outline_colour )
      @offset = fun_factor
    end
    %w(offset outline_colour).each do |method| 
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
    end
  end
  class BarStack < BarBase
    include OWJSON
    def initialize
      super
      @type      = "bar_stack"
    end
    alias_method :append_stack, :append_value
  end
  class BarStackValue < Value
    include OWJSON
    def initialize(val, colour)
      @val = val
      @colour = colour
    end
    %w(val color).each do |method| 
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
    end
  end
  
  class HBarValue
    include OWJSON
    def initialize( left, right )
      @left = left
      @right = right
    end
    %w(left right).each do |method| 
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method}", a)
      end
    end
  end
  class HBar
    include OWJSON
    def initialize(colour = "#9933CC", text = '', font_size = '10px')
      @type      = "hbar"
      @colour    = colour
      @text      = text
      set_font_size font_size
      @values    = []
    end
    %w(colour text font_size values).each do |method| 
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
    end
    # v suppostu be HBarValue class
    def append_value( v )
      @values << v		
    end
    alias_method :<<, :append_value
  end
  
  ########## pie
  class PieValue
    include OWJSON
    def initialize( value, text )
      @value = value
      @text = text
    end
  end

  class Pie
    include OWJSON
    def initialize(colours = ["#d01f3c","#356aa0","#C79810"], alpha = 0.6, border = 2, values = [2,3, PieValue.new(6.5, "hello (6.5)")])
      @type      		= 'pie'
      @colours     		= colours
      @alpha			= alpha
      @border			= border
      @values			= values
    end
    %w(colours alpha border values animate start_angle).each do |method| 
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method.gsub('_','__')}", a)
      end
    end
  end
end
