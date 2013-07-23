def sqrt(num)
  raise ArgumentError.new("Your number was bad") if num <= 0
end

begin
  sqrt(1)

rescue ArgumentError => e
  puts "Woah I caught a bad thing"
  puts e.message

ensure
  puts "Ensure Ran"
end