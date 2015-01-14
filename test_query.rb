require 'uri'
require 'net/http'
require 'json'
require 'launchy'

url = "http://api.repo.nypl.org/api/v1/items/search.json?q=bears"
uri = URI.parse(url)
http = Net::HTTP.new(uri.host, uri.port)

token = ENV['NYPL_API_KEY']

headers = { "Authorization" => "Token token=#{token}" }
request = Net::HTTP::Get.new(uri.request_uri, headers)
response = http.request(request)
@response = response.body	

json_response = JSON.parse(@response)['nyplAPI']['response']['result']
json_response.each do |record|
	p record['itemLink']
end
