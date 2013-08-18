require 'gibson'

g = Gibson::Client.new

p g.set 0, 'foo', '0'
p g.set 0, 'fuu', 'hi'
10.times {
  p g.dec 'foo'
}

puts
puts 'MGET f'

g.mget('f').each do |key,value| 
  puts "#{key}: #{value}"
end


puts
puts 'Get on not-existing key'
begin
  p g.get 'not-existing'
rescue Gibson::NotFoundError
  g.set 0, 'not-existing', 'now i exist'
  p g.get 'not-existing'
end

puts
puts 'STATS'
g.stats.each do |key,value|
  puts "#{key}: #{value}"
end

g.end
