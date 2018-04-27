-- lets the windows accumulate more data
set 'commit.interval.ms'='2000';
set 'cache.max.bytes.buffering'='10000000';
set 'auto.offset.reset'='earliest';

DROP STREAM mesh_stream;
CREATE STREAM mesh_stream (request_scheme VARCHAR, request_size INTEGER, request_time BIGINT,request_host VARCHAR,request_path VARCHAR,request_method VARCHAR,response_duration INTEGER,response_code INTEGER, source_port INTEGER) 
    with ( TIMESTAMP='request_time',VALUE_FORMAT = 'JSON',KAFKA_TOPIC = 'nginmesh');
 
DROP TABLE request_per_min;
CREATE TABLE request_per_min  AS SELECT request_path,count(*) AS events FROM mesh_stream window TUMBLING ( size 60 seconds) GROUP BY request_path;


DROP TABLE request_per_min_max_avg;
CREATE TABLE request_per_min_max_avg  AS SELECT request_path,min(events) AS min, max(events) AS max,  sum(events)/count(events) from request_per_min WINDOW TUMBLING (size 60 second) GROUP BY request_path;

DROP TABLE request_activity;
CREATE TABLE request_activity AS SELECT request_path,request_method, request_size, COUNT(*) AS count FROM mesh_stream WINDOW TUMBLING (size 60 second) GROUP BY request_path,request_method,request_size;

