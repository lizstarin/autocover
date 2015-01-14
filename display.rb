require 'query'

@display_file = "index.html"
File.open(@display_file, "w")

template = File.read("covers.html.erb")
renderer = ERB.new(template)

File.open(@display_file, "a") {|f| f.write(renderer.result()) }
