watch( '^lib/cptn_ruby/.*\.rb' )  do |md|
  puts "File #{md} was modified."
  puts 'Telling Captain Ruby to reload code.'
  system('rake reload')
end

puts 'Watching Captain Ruby source files.'