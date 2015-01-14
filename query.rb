require 'uri'
require 'net/http'
require 'json'
require 'cgi'
require 'erb'

def query_with_terms(search_terms)
	url = "http://api.repo.nypl.org/api/v1/items/search.json?per_page=100&q=#{search_terms}"
	uri = URI.parse(url)
	http = Net::HTTP.new(uri.host, uri.port)

	token = ENV['NYPL_API_KEY']

	headers = { "Authorization" => "Token token=#{token}" }
	request = Net::HTTP::Get.new(uri.request_uri, headers)
	response = http.request(request)	
	
	JSON.parse(response.body)['nyplAPI']['response']['result']
end

def build_book(metadata)
	subjects = []

	title = metadata['title']
	author = metadata['authors'][0] ? metadata['authors'][0]['display_name'] : nil

	metadata['subjects'].each do |s|
		subjects << CGI::escape(s['identifier'].split(' -- ')[0]) if s['type'] == 'LCSH'
	end

	book = {'title' => title, 'author' => author, 'subjects' => subjects}
end


books = []
open('ebookhack/30_metadata.json').each do |line|
	metadata = JSON.parse(line)
	book = build_book(metadata)
	
	subjects = book['subjects']
	search_terms = subjects.join("%20")
	# search_terms = subjects.last
	response = query_with_terms(search_terms)

	book['image_id'] = response.sample['imageID']
	books << book
end

display_file = "index.html"
File.open(display_file, "w")

template = File.read("covers.html.erb")
renderer = ERB.new(template)

File.open(display_file, "a") do |f| 
	f.write('<head><link rel="stylesheet" href="styles.css"></head>')
	f.write(renderer.result()) 
end
