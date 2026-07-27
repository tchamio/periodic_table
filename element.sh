#!/bin/bash

if [[ ! "$1" ]]
then
  echo Please provide an element as an argument.
else

  PSQL="psql --username=freecodecamp --dbname=periodic_table -t -A -c"

  # Identify argument type
  if [[ "$1" =~ [0-9]+ ]]
  then
  echo "search element by id"

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
  where elements.atomic_number = $1;"
  )

  echo "$ELEMENT_RESULT" | sed -E s'/[ | ]/ /g' | while IFS=" " read id symb name mass melting boiling type
  do
    echo "The element with atomic number $id is $name($symb). It's a $type, with a mass of $mass amu. $name has a melting point of $melting celsius and a boiling point of $boiling celsius."
  done

  else
  STR_LENGTH=$(echo -n $1 | wc -m)
  if [[ "$1" =~ ^[A-Z]{1}[a-z]{0,2} && $STR_LENGTH -le 2 ]] 
  then 
    echo "search by symbol"
  else 
    echo "search by name"
  fi  

 fi 
fi