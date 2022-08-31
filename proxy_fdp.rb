require 'fsp/proxies'
require 'sinatra'
require 'sinatra/cross_origin'
require 'rest-client'

BASE_URL = ENV['FSP_PROXY_BASE_URL'] || 'http://fairdata.services:7071/'

set :bind, '0.0.0.0'
configure do
  enable :cross_origin
end
before do
  response.headers['Access-Control-Allow-Origin'] = '*'
end


get '/*' do
  url = BASE_URL + params['splat'].join.to_s
  format = params['format']
  if format
    url += "?format=#{format}"
    resp = RestClient.get(url)
    content_type resp.headers[:content_type]
    resp.body
  elsif !(request.accept?('text/html'))
    warn "\n\nINCOMING REQUEST TYPE #{request.accept}\n\n"
    resp = RestClient::Request.execute({
      method: :get,
      url: url.to_s,
      headers: {"Accept" => "#{request.accept}"},
      :verify_ssl => false
    })
    content_type resp.headers[:content_type]
    resp.body
  else
    warn "\n\nELSE INCOMING REQUEST TYPE #{request.accept}\n\n"
    p = Fsp::Proxies::FairDataPoint.new(url: url)
    p.proxy
    html = p.to_html
    html.gsub!(/<head>/, "<head><base href='#{BASE_URL}'/>")
    #puts "Content-type: text/html\n\n"
    #puts html
    html
  end
end


options "*" do
  response.headers["Allow"] = "GET, PUT, POST, HEAD, DELETE, OPTIONS"
  response.headers["Access-Control-Allow-Headers"] = "Authorization, Content-Type, Accept, X-User-Email, X-Auth-Token"
  response.headers["Access-Control-Allow-Origin"] = "*"
  200
end