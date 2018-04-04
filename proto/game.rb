require 'json'

class Array
  def second; return self[1];     end
  def third;  return self[2];     end
  def rest;   return self[1..-1]; end
end

$stuff = JSON.parse(File.read("stuff.json"))
$rooms = JSON.parse(File.read("rooms.json"))
$inventory = []
$room = "start"
$energy = 10
$light = false

def look
  if $rooms[$room]["dark"] and !$light then
    puts "It's too dark, you can't see anything."
  else
    puts $rooms[$room]["summary"]
    things = $rooms[$room]["inventory"]
    if things.length.zero? then
      puts "You see nothing."
    else
      puts "You see:"
      things.each do |thing|
        puts "\t#{thing}"
      end
    end
  end
end

def handle(line)
  a = line.split
  case a.first
  when "look"
    if a.second == "me" || a.second == "self" then
      puts "A daring adventurer."
      puts "HP: #{$energy}"
      handle "inventory"
    else
      look
    end
  when "take", "get"
    if $rooms[$room]["inventory"].include?(a.second) then
      $inventory << a.second
      $rooms[$room]["inventory"].delete(a.second)
      puts "You take the #{a.second}."
    else
      puts "You can't see a(n) #{a.second}."
    end
  when "north", "south", "east", "west"
    handle "go #{a.first}"
  when "go"
    $room = $rooms[$room][a.second]
    look
  when "inventory"
    if $inventory.length.zero? then
      puts "You have nothing."
    else
      puts "You have:"
      $inventory.each do |thing|
        puts "\t#{thing}"
      end
    end
  when "light"
    if $inventory.include?(a.second) then
      if $stuff[a.second]["light"] then
        puts "You light the #{a.second}."
        $light = true
      else
        puts "You can't light that."
      end
    else
      puts "You don't have a(n) #{a.second} to light."
    end
  when "snuff"
    if $inventory.include?(a.second) then
      if $stuff[a.second]["light"] then
        puts "You snuff the #{a.second}."
        $light = false
      else
        puts "You can't light that, let alone snuff it."
      end
    else
      puts "You don't have a(n) #{a.second} to snuff."
    end
  when "eat"
    if $inventory.include?(a.second) then
      if $stuff[a.second]["edible"] then
        $energy += $stuff[a.second]["energy"]
        puts "A tasty #{a.second}"
        $inventory.delete(a.second)
      else
        puts "You can't eat that."
      end
    else
      puts "You don't have a(n) #{a.second} to eat."
    end
  end
end

look

loop do
  print ">: "
  line = gets.strip.downcase
  handle(line)
end
