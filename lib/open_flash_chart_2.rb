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
    def method_missing(method_id, *arguments)
      a = arguments[0] if arguments and arguments.size > 0
      method = method_id.to_s
      if method =~ /^(.*)(=)$/
        self.instance_variable_set("@#{$1.gsub('_','__')}", a)
      elsif method =~ /^(set_)(.*)$/
        self.instance_variable_set("@#{$2.gsub('_','__')}", a)
      elsif self.instance_variable_defined?(method_id)
        self.instance_variable_get("@#{method_id.to_s.gsub('_','__')}") # that will be return instance variable value or nil, handy
      else
        #        super # well there is no instance variable and user don't wan't to define any, maybe better return nil?
        warn("!!! there is no instance variable named #{method_id} !!!")
        nil
      end
    end
  end

  def self.included(controller)
    controller.helper_method(:ofc2, :ofc2_inline)
  end

  # generate a ofc object using Graph object
  # +width+ width for div
  # +height+ height for div
  # +graph+ a OFC2::Graph object
  # +base+ uri for graph, default '/'
  # +id+ id for div with graph, default Time.now.usec
  def ofc2_inline(width, height, graph, base='/', id=Time.now.usec)
    # TODO: generating more than one graph with ofc2_inline on the same page is currently impossible
    div_name = "flashcontent_#{id}"
    <<-EOF
      <div id="#{div_name}"></div>
      <script type="text/javascript">
        #{div_name} = '#{graph.render}';

        function open_flash_chart_data(){
          return #{div_name};
        };

        // i'm not shure that is necessary
        function findSWF(movieName) {
          if (navigator.appName.indexOf("Microsoft")!= -1) {
            return window[movieName];
          } else {
            return document[movieName];
          }
        };

        swfobject.embedSWF(
          '#{base}open-flash-chart.swf', '#{div_name}',
          '#{width}', '#{height}','9.0.0', 'expressInstall.swf'
        );
      </script>
    EOF
  end

  # generate a ofc object using data from url
  # +width+ width for div
  # +height+ height for div
  # +url+ an url which return data in json format
  # +base+ uri for graph, default '/'
  # +id+ id for div with graph, default Time.now.usec
  def ofc2(width, height, url, base='/', id =Time.now.usec)
    div_name = "flashcontent_#{id}"
    <<-EOF
      <div id='#{div_name}'></div>
      <script type="text/javascript">
        swfobject.embedSWF(
        "#{base}open-flash-chart.swf","#{div_name}",
        "#{width}", "#{height}", "9.0.0", "expressInstall.swf",
        {"data-file":"#{base}#{url}"} );
      </script>
    EOF
  end

=begin
  insance variables:
  +style+ :style for element, it's is in css style eg. "{font-size: 20px; color: #FF0F0F; text-align: center;}"
  +text+ :text for element
=end
  class Element
    include OWJSON
    def initialize(text = '', css = "{font-size: 20px; color: #FF0F0F; text-align: center;}")
      set_text(text)
      set_style(css)
    end
  end

=begin
  documentation is the same as Element class
=end
  class XLegend <  Element ;end
=begin
  documentation is the same as Element class
=end
  class Title < Element ;end
=begin
  documentation is the same as Element class
=end
  class YLegend <  Element ;end


=begin
  y_axis
  +stroke+
  +tick_length+
  +colour+
  +min+
  +max+
  +steps+
  +labels+
=end
  class YAxisBase
    include OWJSON

    # set colour and grid_colour at once
    # there is also an alias colours=
    # +colour+ colour for labels eg. #FF0000
    # +grid_colour+ colour for grid eg. #00FF00
    def set_colours( colour, grid_colour )
      set_colour( colour )
      set_grid_colour( grid_colour )
    end
    alias_method :colours=, :set_colours


    # set range at once
    # there is also an alias range=
    # +min+ minimum for y_axis
    # +max+ maximum for y_axis
    # +steps+ how many steps skip before print label
    def set_range( min, max, steps=1 )
      set_min(min)
      set_max(max)
      set_steps( steps )
    end
    alias_method :range=, :set_range

    # set offset for axis, these is handy when You want to 3d graph render
    # there is also an alias offset=
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

=begin
  x_axis
  +stroke+
  +tick_length+
  +colour+
  +tick_height+
  +grid_colour+
  +min+
  +max+
  +steps+
  +labels+
  +offset+
=end
  class XAxis
    include OWJSON

    # well it must be done this way because instance variable name can't be started by number
    %w(3d).each do |method|
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@___#{method}", a)
      end
      define_method("_#{method}=") do |a|
        self.instance_variable_set("@___#{method}", a)
      end
      define_method("#{method}") do
        self.instance_variable_get("@___#{method}")
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
    # helper method to make the examples
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
    # instance variables
    # text colour size rotate visible
    #    %w(text colour size rotate visible).each do |method|
    #      define_method("set_#{method}") do |a|
    #        self.instance_variable_set("@#{method.gsub('_','__')}", a)
    #      end
    #      define_method("#{method}=") do |a|
    #        self.instance_variable_set("@#{method.gsub('_','__')}", a)
    #      end
    #      define_method("#{method}") do
    #        self.instance_variable_get("@#{method.gsub('_','__')}")
    #      end
    #    end
    def set_vertical
      @rotate = "vertical"
    end
    alias_method :vertical, :set_vertical
  end
  class XAxisLabels
    include OWJSON
    # instance variables
    # steps labels colour size
    #    %w(steps labels colour size).each do |method|
    #      define_method("set_#{method}") do |a|
    #        self.instance_variable_set("@#{method}", a)
    #      end
    #      define_method("#{method}=") do |a|
    #        self.instance_variable_set("@#{method}", a)
    #      end
    #      define_method("#{method}") do
    #        self.instance_variable_get("@#{method.gsub('_','__')}")
    #      end
    #    end
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
    # instance variables
    # x dot_size y
    #    %w(x dot_size y).each do |method|
    #      define_method("set_#{method}") do |a|
    #        self.instance_variable_set("@#{method.gsub('_','__')}", a)
    #      end
    #      define_method("#{method}=") do |a|
    #        self.instance_variable_set("@#{method.gsub('_','__')}", a)
    #      end
    #      define_method("#{method}") do
    #        self.instance_variable_get("@#{method.gsub('_','__')}")
    #      end
    #    end
  end
  class Scatter
    include OWJSON
    def initialize( colour, dot_size )
      @type      = "scatter"
      set_colour( colour )
      set_dot_size( dot_size )
    end
    # instance variables
    # colour dot_size values
    #    %w(colour dot_size values).each do |method|
    #      define_method("set_#{method}") do |a|
    #        self.instance_variable_set("@#{method.gsub('_','__')}", a)
    #      end
    #      define_method("#{method}=") do |a|
    #        self.instance_variable_set("@#{method.gsub('_','__')}", a)
    #      end
    #      define_method("#{method}") do
    #        self.instance_variable_get("@#{method.gsub('_','__')}")
    #      end
    #    end
  end


=begin
  +title+
  +x_axis+
  +y_axis+
  +y_axis_right+
  +x_legend+
  +y_legend+
  +bg_colour+
  +elements+
=end
  class Graph
    include OWJSON

    # it must be done in that way because method_miising method replace _ to __
    %w(x_axis y_axis y_axis_right x_legend y_legend bg_colour).each do |method|
      define_method("set_#{method}") do |a|
        self.instance_variable_set("@#{method}", a)
      end
      define_method("#{method}=") do |a|
        self.instance_variable_set("@#{method}", a)
      end
      define_method("#{method}") do
        self.instance_variable_get("@#{method}")
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
      # everything about underscores
      s.gsub!('___','') # that is for @___3d variable
      s.gsub!('__','-') # that is for @smt__smt variables
      # variables @smt_smt should look without changes
      s
    end
  end

=begin
  line chart
  +values+
  +width+
  +colour+
  +font_size+
  +dot_size+
  +halo_size+
  +text+
=end
  class LineBase
    include OWJSON
    def initialize(text = 'label text', font_size='10px', values = [9,6,7,9,5,7,6,9,7])
      @type      = "line_dot"
      @text      = text
      @font__size = font_size
      @values    = values
    end
  end

=begin
  go to class LineBase for details
=end
  class LineDot < LineBase ;end

=begin
  go to class LineBase for details
=end
  class Line < LineBase
    def initialize
      super
      @type      = "line"
    end
  end

=begin
  go to class LineBase for details
=end
  class LineHollow < LineBase
    def initialize
      super
      @type      = "line_hollow"
    end
  end

=begin
  +width+
  +color+
  +values+
  +dot_size+
  +text+
  +font_size+
  +fill_alpha+
=end
  class AreaHollow
    include OWJSON
    def initialize(fill_alpha = 0.35, values = [])
      @type      = "area_hollow"
      set_fill_alpha  fill_alpha
      @values    = values
    end
  end

=begin
  +alpha+
  +colour+
  +values+
  +text+
  +font_size+
=end
  class BarBase
    include OWJSON
    def initialize (values = [], text = '', size = '10px')
      @values = values
      @text = text
      @font__size = size
    end
    def set_key( text, size )s
      @text = text
      @font__size = size
    end
    def append_value( v )
      @values << v
    end
    alias_method :<<, :append_value
  end

=begin
  go to class BarBase for details
=end
  class Bar < BarBase
    def initialize
      @type      = "bar"
    end
  end

=begin
  +top+
  +colour+
  +tip+
=end
  class Value
    include OWJSON
    def initialize(top = 0, color = '', tip = nil)
      @top = top
      @colour = color
      @tip = tip
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

=begin
 go to class BarBase documentation for details
=end
  class BarGlass < BarBase
    def initialize()
      @type      = "bar_glass"
    end
  end

=begin
 go to class BarBase documentation for details
  +offset+
  +colour+
  +outline_colour+
=end
  class BarSketch < BarBase
    def initialize( colour = '#ff0000', outline_colour = '#00FF00', fun_factor = 5)
      @type      = "bar_sketch"
      set_colour( colour )
      set_outline_colour( outline_colour )
      @offset = fun_factor
    end
  end

=begin
 go to class BarBase documentation for details
=end
  class BarStack < BarBase
    include OWJSON
    def initialize
      super
      @type      = "bar_stack"
    end
    alias_method :append_stack, :append_value
  end

=begin
 go to class Value documentation for details
  +val+
  +color+
=end
  class BarStackValue < Value
    include OWJSON
    def initialize(val, colour)
      @val = val
      @colour = colour
    end
  end

=begin
  +left+
  +right+
=end
  class HBarValue
    include OWJSON
    def initialize( left, right )
      @left = left
      @right = right
    end
  end

=begin
  +colour+
  +text+
  +font_size+
  +values+
=end
  class HBar
    include OWJSON
    def initialize(colour = "#9933CC", text = '', font_size = '10px')
      @type      = "hbar"
      @colour    = colour
      @text      = text
      set_font_size font_size
      @values    = []
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
      @value  = value
      @text   = text
    end
  end

=begin
  +colours+
  +alpha+
  +border+
  +values+
  +animate+
  +start_angle+
=end
  class Pie
    include OWJSON
    def initialize(colours = ["#d01f3c","#356aa0","#C79810"], alpha = 0.6, border = 2, values = [2,3, PieValue.new(6.5, "hello (6.5)")])
      @type     = 'pie'
      @colours  = colours
      @alpha	= alpha
      @border	= border
      @values	= values
    end
  end
end
