#!/usr/bin/ruby
require 'rubygems'
require 'google_hash'
require 'csv'
require 'pp' 
require "faster_csv"

STDOUT.sync=true

if ARGV[0] == "" or ARGV[0] == nil
  puts "The script needs as an argument the directory"
end

directory = ARGV[0]

puts "Processing directory #{directory}"

numbers = Array.new

Dir.entries("#{directory}/converted_data").each do |file|
  if file.include?(".") and file.length > 5
    numbers.push(file.split(".")[0].to_i)
  end
end

numbers = numbers.uniq.sort

name = directory.split("-dir")[0]

try = %x[rm processed/processed#{name}.csv]
puts try


numbers.each do |num|
  key2event = Hash.new #Hash.new
  
  puts "Proceso a la posicion #{num}"
  puts "Cargo eventos de #{num.to_s}.crc2event.csv"
  countz = 0
  FasterCSV.foreach("#{directory}/converted_data/#{num.to_s}.crc2event.csv") do |line|
        key = line[1]
        #puts key
        countz = countz + 1
        if key2event[key] == nil
          key2event[key] = Array.new
        end
        key2event[key].push(line[0])
        
        if countz % 10000 == 0
          puts countz
        end
    end
    cantidad = 0
    key2event.each do |key, value|
      cantidad += value.length 
    end
    puts "Loaded #{cantidad} elements"

  keys = Array.new
  puts "Ahora cargo las conexiones del archivo #{num.to_s}.crc2key.csv"
  CSV.foreach("#{directory}/converted_data/#{num.to_s}.crc2key.csv") do |line|
      keys.push(line)
  end
  puts "Loaded #{keys.length} key elements"
  
  eventos = GoogleHashDenseRubyToRuby.new #Hash.new
  
  puts "GENERO UN HASH DE EVENTOS, CON KEY ES EL ID DEL EVENTO"
  count = 0
  puts "Now loading the events of file #{num.to_s}.events.csv"
  CSV.foreach("#{directory}/converted_data/#{num.to_s}.events.csv") do |line|
    begin
      evento = line[1]
      count = count + 1
      eventos[evento] = line
    rescue
      puts "ERROR CON #{line[1]}"
    end
  end
  puts "Now loading the events of file #{num.to_s}.events2.csv"
  path = "#{directory}/converted_data/#{num.to_s}.events2.csv"

  FasterCSV.foreach(path) do |line|
      count = count + 1
      evento = line[1]
      eventos[evento] = line
      if count % 10000 == 0
        puts count
      end
  end
  puts "Loaded #{eventos.length} elements"  

  puts "Hago un ejemplo: Agarro el primer elemento de keys"

  keys.each do |key|
    keyid = key[0]
    puts "Keyid es #{keyid}"
    eventid = key2event[keyid]
    #pp key2event
    if eventid != nil
      puts "El primer elemento es #{keyid}"
      puts "Relaciono la conex con #{eventid.length} eventos"
      eventid.each do |event|
        eventmsg = eventos[event]
      #  puts "Encuentro el evento #{event} con mensaje #{eventmsg}"
      end
      break
    end
  end
  
  puts "Creating file processed/processed#{name}.csv ..."
  
  name = directory.split("-dir")[0]
  
  counting = 0
  FasterCSV.open("processed/processed#{name}.csv", "a") do |csv|
    counting = counting + 1
    keys.each do |key|
      keyid = key[0]
      events = key2event[keyid]
      events.each do |event|
        ev = eventos[event]
        begin
          key.map!{ |element| element.gsub("\n","") if element != nil }
        rescue
          puts "Error with key"
          pp key
          $stdin.gets.chomp()
        end
        begin
          ev.map!{ |element| element.gsub("\n","") if element != nil }
        rescue
          puts "Error con event"
          pp ev
        end
        
        if counting % 10000 == 0
          puts "Veo a #{counting} con key:"
        end
        csv << key + ev
      end
    end  
  end
end
