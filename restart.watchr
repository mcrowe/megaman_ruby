watch( '^lib/ctpn_ruby/.*\.rb' )  {|md| system('rake restart') }
$stderr.puts 'Watching lib files so we can restart the game.'