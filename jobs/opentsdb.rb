require 'net/http'
require 'json'
require 'date'

# Pull data from OpenTSDB and make available to Dashing Widgets
# Tested with v2.0.0 from http://opentsdb.net/

# Set the host and port
OPENTSDB_HOST = '127.0.0.1' # specifiy the base url of your OpenTSDB
OPENTSDB_PORT = 4242 # specify the port of the server here

# Job mappings. Define a name and set the Sub Query 
# More examples can be found in OpenTSDB API documentation
# http://opentsdb.net/docs/build/html/api_http/query/index.html

job_mapping = {
    'proc-stat-idle-foo' => 'sum:rate:proc.stat.cpu{host=foo,type=idle}',
    'proc-stat-wait-bar' => 'sum:rate:proc.stat.cpu{host=bar,type=wait}'
}

class OpenTSDB
    # Initialize the class
    def initialize(host, port)
        @host = host
        @port = port
    end

    # Use OpenTSDB api to query for the stats, parse the returned JSON and return the result
    def query(statname, since=nil)
        since ||= '1h-ago'
        http = Net::HTTP.new(@host, @port)
        response = http.request(Net::HTTP::Get.new("/api/query?start=#{since}&m=#{statname}"))
        result = JSON.parse(response.body, :symbolize_names => true)
        return result.first
    end

    # Gather the datapoints and turn into Dashing graph widget format
    def points(name, since=nil)
        stats = query name, since
        dps = stats[:dps]

        points = []
        last = 0
        count = 1

        (dps.select { |el| not el.nil? }).each do|item|
            points << { x: count, y: item[1].round(4) }
            count += 1
            last = item[1].round(4)
        end

        return points, last
    end
end

job_mapping.each do |title, statname|
   SCHEDULER.every '30s', :first_in => 0 do
        # Create an instance of our opentsdb class
        q = OpenTSDB.new OPENTSDB_HOST, OPENTSDB_PORT

        # get the current points and value. Timespan is static atm
        points, current = q.points "#{statname}", "1h-ago"

        # send to dashboard, so the number the meter and the graph widget can understand it
	send_event "#{title}", { current: current, value: current, points: points }
   end
end
