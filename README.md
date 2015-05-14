# KataCurl-ElastiSearch
KataCurl ElasticSearch Scripts

### USAGE ###

    export ES_URL_FROM="http://url_es_src:9200"
    export ES_URL_TO="http://url_es_dest:9200"
    export ES_INDEX=test
    
    export ES_INDEX_SRC=test   #OPTION
    export ES_INDEX_DEST=test2 #OPTION
    
    /bin/sh -c es.mappings.katacurl.sh

### LICENCE ###
* GNU

### CREDITS ###
* http://stedolan.github.io/jq/

### Build 0.1.5-5 ###
Release Date: 14 may 2015

* add option index src and index dest
* add shl/json/sample.json (TODO)
* es.katacurl.mappings.sh

