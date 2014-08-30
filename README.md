##OpenTSDB Support for Dashing
Pull data from OpenTSDB and present in Dashing. Support both graph and number widget. Examples for how to write OpenTSDB Sub Queries can be found at 
http://opentsdb.net/docs/build/html/api_http/query/index.html

##Usage
1. Copy `opentsdb.rb` to jobs directory

2. Make sure the required gems are installed

```
gem install 'net/http'
gem install 'json'
gem install 'date'
```

3. Configure the `jobs/opentsdb.rb` to pull the required stats:

```
OPENTSDB_HOST = 'localhost' 
OPENTSDB_PORT = 4242 

job_mapping = {
   'web-server-load' => 'sum:proc.loadavg.5min{host=web.server.net}',
   'other-server-load' => 'sum:proc.loadavg.5min{host=other.server.net}'
}

```

4. Configure dashboard to use your data.
Add to your dashboard file, for instance `dashboards/sample.erb`

```
    <li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
        <div data-id="web-server-load" data-view="Graph" data-title="Web Server Load" data-moreinfo="Last 4h"></div>
    </ul>
    <li data-row="1" data-col="1" data-sizex="1" data-sizey="1">
        <div data-id="other-server-load" data-view="Graph" data-title="Web Server Load" data-moreinfo="Last 4h"></div>
    </ul>
```

