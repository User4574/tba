exit 1 if ARGV.empty?

$thingfactories = {}
$roomfactories = {}
$rooms = {}

class ThingFactory
  def initialize(name, block)
    @name = name
    @properties = []
    @energy = 0
    self.instance_eval(&block)
  end

  def property(*strs)
    strs.each do |str|
      @properties << str
    end
  end

  def energy(num)
    @energy = num
  end

  def create
    return Thing.new(@name, @properties, @energy)
  end

  attr_reader :name
end

class Thing
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

class RoomFactory
  def initialize(block)
    @description = ""
    @properties = []
    @inventory = []
    @north = nil
    @south = nil
    @east = nil
    @west = nil
    self.instance_eval(&block)
  end

  def description(description)
    @description = description
  end

  def property(str)
    @properties << str
  end

  def inventory(*strs)
    strs.each do |str|
      @inventory << str
    end
  end

  def north(str)
    @north = str
  end

  def south(str)
    @south = str
  end

  def east(str)
    @east = str
  end

  def west(str)
    @west = str
  end

  def create
    return Room.new(@description, @properties, @inventory, @north, @south, @east, @west)
  end
end

class Room
  def initialize(description, properties, inventory, north, south, east, west)
    @description = description
    @properties = properties
    @inventory = inventory
    @north = north
    @south = south
    @east = east
    @west = west
  end

  def reify!(roomhash)
    t = []
    @inventory.each do |str|
      t << $thingfactories[str].create
    end
    @inventory = t

    @north = roomhash[@north] unless @north.nil?
    @south = roomhash[@south] unless @south.nil?
    @east  = roomhash[@east ] unless @east.nil?
    @west  = roomhash[@west ] unless @west.nil?
  end

  def take(thing)
    matches = @inventory.select do |thg|
      thg.name == thing
    end

    return @inventory.delete(matches[0])
  end

  def put(thing)
    @inventory << thing
  end

  def has_property(str)
    return @properties.include?(str)
  end

  def method_missing(name)
    if name.to_s =~ /^is_(.*)\?$/ then
      has_property($1)
    end
  end

  attr_reader :description, :inventory, :north, :south, :east, :west
end



def room(name, &block)
  factory = RoomFactory.new(block)
  $roomfactories[name] = factory
end

def thing(name, &block)
  factory = ThingFactory.new(name, block)
  $thingfactories[name] = factory
end



def createRooms
  $roomfactories.each do |name, factory|
    $rooms[name] = factory.create
  end
  $rooms.each do |_, room|
    room.reify!($rooms)
  end
end

load ARGV.shift.strip
createRooms



puts "ERROR 1" unless $rooms["start"].east == $rooms["start"]
puts "ERROR 2" unless $rooms["another"].is_dark?
puts "ERROR 3" unless $rooms["another"].take("lamp").nil?
puts "ERROR 4" if $rooms["another"].take("apple").nil?
