#!/bin/bash

$id = $1
$pwd = $2

if [[ uname -a | grep -i 'Ubuntu' == "Ubuntu" ]]; then
    echo "Ubuntu"
  elif [[ uname -a  | grep -i 'el7']] then
    # TODO We'll need to attempt some magic to extract the filename
    echo uname -a
  fi


  function