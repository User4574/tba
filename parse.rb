exit 1 if ARGV.empty?

$things = []
$rooms = []

class ThingFactory
  def self.create_thing(block)
    ThingFactory.new(block).to_thing
  end

  def initialize(block)
    @name = ""
    @properties = []
    @energy = 0
    self.instance_eval(&block)
  end

  def name(str)
    @name = str
  end

  def property(str, *strs)
    @properties << str
    @properties += strs
  end

  def energy(num)
    @energy = num
  end

  def to_thing
    return Thing.new(@name, @properties, @energy)
  end
end

class Thing
  def self.parse(block)
    return ThingFactory.create_thing(block)
  end

  def initialize(name, properties, energy)
    @name = name
    @properties = properties
    @energy = energy
  end

  def has_property(str)
    return @properties.include?(str)
  end

  def method_missing(name)
    if name.to_s =~ /^is_(.*)\?$/ then
      has_property($1)
    end
  end

  attr_reader :name
  attr_accessor :energy
end



def room(&block)
  #return Room.parse(block)
end

def thing(&block)
  $things << Thing.parse(block)
end




load ARGV.shift.strip
