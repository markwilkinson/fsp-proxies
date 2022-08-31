require 'fsp/proxies'
require 'sinatra'
require 'rest-client'

BASE_URL = ENV['FSP_PROXY_BASE_URL'] || 'http://fairdata.services:7071/'

# get '/*' do
#   url = BASE_URL + params['splat'].join.to_s
#   url + params.to_s
# end
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


