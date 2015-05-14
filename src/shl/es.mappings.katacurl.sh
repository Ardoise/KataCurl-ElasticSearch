#!/bin/bash -e

#TODO es.mappings.katacurl.sh @myfile.json
#TODO es.mappings.katacurl.sh -d '{}'
cat <<EOF
# =================================================
# USAGE
# tape> export ES_URL_FROM="http://url_es_src:9200"
# tape> export ES_URL_TO="http://url_es_dest:9200"
# tape> export ES_INDEX=test
#
# tape> export ES_INDEX_SRC=test1    #OPTION
# tape> export ES_INDEX_DEST=test1   #OPTION
#
# tape> /bin/sh -c es.mappings.katacurl.sh
#
# =================================================
EOF

#case $@ in
#  @)
#
#    ;;
#  -d)
#
#    ;;
#esac

#WEB
echo "# .dockerfile";
echo "MAINTENER eTopaze";
echo "USER $(id -un)";
echo "FROM kataCurl";
echo "LABEL KATACURL elasticsearch";
ES_URL_DEFAULT="http://127.0.0.1:9200"; echo "ENV ES_URL_DEFAULT=${ES_URL_DEFAULT}";
ES_URL_FROM=${ES_URL_FROM:-$ES_URL_DEFAULT}; echo "ENV ES_URL_FROM=${ES_URL_FROM}";
ES_URL_TO=${ES_URL_TO:-$ES_URL_DEFAULT}; echo "ENV ES_URL_TO=${ES_URL_TO}";
ES_INDEX_DEFAULT=test; echo "ENV ES_INDEX_DEFAULT=${ES_INDEX_DEFAULT}";
ES_INDEX=${ES_INDEX:-$ES_INDEX_DEFAULT}; echo "ENV ES_INDEX=${ES_INDEX}";
ES_INDEX_SRC=${ES_INDEX_SRC:-$ES_INDEX}; echo "ENV ES_INDEX_SRC=${ES_INDEX_SRC}";
ES_INDEX_DEST=${ES_INDEX_DEST:-$ES_INDEX}; echo "ENV ES_INDEX_DEST=${ES_INDEX_DEST}";


[[ "${ES_URL_FROM}" == "${ES_URL_TO}" ]] && (
  cmd="WARN : ES_URL_FROM='${ES_URL_FROM}' == ES_URL_TO='${ES_URL_TO}' are the same."
  echo "RUN echo '${cmd}'";
  exit 1
)

function require_jq {
  case `lsb_release -i -s` in
    Ubuntu,Debian)
      cmd="sudo apt-get -y install jq";
      echo "RUN $cmd";
      eval $cmd;
    ;;
    Redhat|Fedora|CentOS)
      cmd="sudo yum -y install jq";
      echo "RUN $cmd";
      eval $cmd;
    ;;
    *)
      #==========
      echo -e "\n#   Install JSONQuery Parser";
      #==========
      vjq=$(jq --version |awk -F'-' '{print $2}'); echo "ENV vjq=${vjq}";
      if [[ "$vjq" < "1.3" ]]; then
        case $(uname -m) in
          *64) #64 bits = x86_64
            echo "#   Requirements JQ##64b successful";
            curl -OL http://stedolan.github.io/jq/download/linux64/jq;
          ;;
          *) #32bits = i386, i686
            echo "#   Requirements JQ##32b successful";
            curl -OL http://stedolan.github.io/jq/download/linux32/jq;
          ;;
        esac
        chmod a+x jq* ; mv jq* /usr/bin/;
      fi
      echo "#   Requirements JQ##${vjq} successful";
    ;;
  esac
  vjq=$(jq --version |awk -F'-' '{print $2}'); echo "ENV vjq=${vjq}";
}

function es-copy-mapping-curl {
  ARG1=${1:-$ES_INDEX_SRC};    #index source
  ARG2=${2:-$ES_INDEX_DEST};   #index destination

  echo -e "\n#COPY SETTINGS,MAPPINGS,ALIASES,WARNERS $ARG1 from url_source to url_dest";
  
  #REQUIRES
  [ -x $(which jq) ] || (
    require_jq
  )

  [ -x $(which jq) ] || (
    echo "#ERROR : jq(json query) was not installed/detected !"
    exit 1 ; 
  )
  # CURL METHODE
  # for-each [ index ]
  #   es-export ((_settings,_mappings), _aliases, _warmers) $ARG1 ${ES_URL_FROM}_url
  #   es-import ((_settings,_mappings), _aliases, _warmers) $ARG2 ${ES_URL_TO}_url
  cmd="curl -XGET '${ES_URL_FROM}/${ARG1}/_settings,_mapping,_aliases,_warmers' |jq '.${ARG1}' >/tmp/${ARG1}.smaw.json"; 
  echo "RUN ${cmd}";
  eval ${cmd}; 

  cmd="ls -ail /tmp/${ARG1}.smaw.json";
  echo "RUN ${cmd}";

  cmd="curl -XPUT '${ES_URL_TO}/${ARG2}' -d @/tmp/${ARG1}.smaw.json && echo"; 
  echo "RUN ${cmd}"; 
  eval ${cmd};
}

function es-process-data {
  ARG1=${1:-$ES_INDEX_SRC};    #index source
  ARG2=${2:-$ES_INDEX_DEST};   #index destination

  echo -e "\n#PROCESS\n";

  [ -z "$ARG1" ] && exit 1
  [ -z "$ARG2" ] && exit 1
  
  es-copy-mapping-curl ${ARG1} ${ARG2};   #copy MAPPING from ${ES_URL_FROM}/${ARG1} to ${ES_URL_TO}/${ARG2}
}

# ==== MAIN ===
es-process-data
