require "net/http"
require "uri"
require "terminal-notifier"

URL     = 'https://www.dmv.ca.gov/wasapp/webdata/output3.txt'
OFFICES = { '506' => 'hillcrest', '519' => 'clairemont' }

def execute
  response = dmv_response
  parse_and_report(response)
end

def dmv_response
  uri = URI.parse(URL)
  Net::HTTP.post_form(uri, {})
end

def parse_and_report(response)
  regex   = /(506),\d*,(\d*),|(519),\d*,(\d*),/
  results = response.body.scan(regex)

  results.each do |info|
    office_id, wait_time = info.compact
    puts "#{OFFICES[office_id].capitalize}: #{wait_time} minutes"

    notify(office_id, wait_time) if wait_time.to_i <= 15
  end
end

def notify(office_id, wait_time)
  TerminalNotifier.notify(
    "#{OFFICES[office_id].capitalize} wait is at #{wait_time} minutes",
    title: 'DMV Wait Time Alert'
  )
end

execute