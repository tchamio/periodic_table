#!/bin/bash

search_element() {
  PSQL="psql --username=freecodecamp --dbname=periodic_table -t -A -c"

  local condition=$1

  ELEMENT_RESULT=$($PSQL "select 
    elements.atomic_number, 
    elements.symbol, 
    elements.name, 
    properties.atomic_mass, 
    properties.melting_point_celsius, 
    properties.boiling_point_celsius, 
    types.type 
    from elements 
    inner join properties on elements.atomic_number = properties.atomic_number 
    left join types on properties.type_id = types.type_id 
    where $condition ;"
  );

  echo "$ELEMENT_RESULT"
}

format_response() {
  local ELEMENT_RESULT=$1

  if [[ -z "$ELEMENT_RESULT" ]]
  then
    echo "I could not find that element in the database."
  else
    echo "$ELEMENT_RESULT" | sed -E s'/[ | ]/ /g' | while IFS=" " read id symb name mass melting boiling type
    do
      echo "The element with atomic number $id is $name ($symb). It's a $type, with a mass of $mass amu. $name has a melting point of $melting celsius and a boiling point of $boiling celsius."
    done
  fi
}

if [[ ! "$1" ]]
then
  echo Please provide an element as an argument.
else
  # Search condition based on arg type
  if [[ "$1" =~ [0-9]+ ]]
  then
    SEARCH_CONDITION="elements.atomic_number = $1"
  else
    STR_LENGTH=$(echo -n $1 | wc -m)

    if [[ "$1" =~ ^[A-Z]{1}[a-z]{0,2} && $STR_LENGTH -le 2 ]] 
    then 
      SEARCH_CONDITION="elements.symbol = '$1'"
    else 
      SEARCH_CONDITION="elements.name = '$1'"
    fi  
  fi

  SEARCH_RESULT=$(search_element "$SEARCH_CONDITION")

  format_response "$SEARCH_RESULT"

fi