
# Run an Webserver on Ambari Server to share blueprint

``` python -m SimpleHTTPServer ```

# Run Ambari-shell on docker

``` docker run -it --rm  sequenceiq/ambari-shell --ambari.host=master1 --ambari.port=8080 ```` 

# Run Ambari-shell commands

```
Ambari-Shell> blueprint add --url http://master1:8000/blueprint-ranger.json 
Ambari-Shell> cluster create --blueprint scigillity-ranger
Ambari-Shell> host add --hostGroup host_group_1 --host master1.hortonworks.local§
Ambari-Shell> host add --hostGroup host_group_2 --host slave1.hortonworks.local§
Ambari-Shell> host add --hostGroup host_group_3 --host slave2.hortonworks.local§
Ambari-Shell> cluster create
```
