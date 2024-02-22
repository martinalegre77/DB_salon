#! /bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ Salon Appointment Scheduler ~~~~~\n"

SERVICE_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi
  LIST_SERVICES=$($PSQL "SELECT service_id, name FROM services")
  echo "$LIST_SERVICES" | while read SERVICE_ID BAR NAME
  do
    echo "$SERVICE_ID) $NAME"
  done
  echo -e "\nEnter your choice:"

  read SERVICE_ID_SELECTED
  CHOSEN_SERVICE=$($PSQL "SELECT service_id, name 
  FROM services 
  WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $CHOSEN_SERVICE ]]
  then 
    SERVICE_MENU
  else
    # get customer info
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers 
    WHERE phone = '$CUSTOMER_PHONE'")
    # if customer doesn't exist
    if [[ -z $CUSTOMER_ID ]]
    then
      # get new customer name
      echo -e "\nWhat's your name?"
      read CUSTOMER_NAME
      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) 
      VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')") 
    fi
    # get customer_id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers 
    WHERE phone='$CUSTOMER_PHONE'")
    # get time
    echo -e "\nWhat is the time?"
    read SERVICE_TIME
    # insert appointment
    INSERT_APPOINTMENT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) 
    VALUES($CUSTOMER_ID, '$SERVICE_ID_SELECTED', '$SERVICE_TIME')")

    # get appointment info
    APPOINMENT_INFO=$($PSQL "SELECT s.name, time, c.name 
    FROM services AS s 
    INNER JOIN appointments USING(service_id) 
    INNER JOIN customers AS c USING(customer_id) 
    WHERE service_id=$SERVICE_ID_SELECTED
    AND customer_id=$CUSTOMER_ID
    AND time='$SERVICE_TIME'")
    APPOINMENT_INFO_FORMATTED=$(echo $APPOINMENT_INFO | sed 's/ |/ at/ ; s/ |/,/ ; s/^ *| *$//g')
    # send to main menu
    echo "I have put you down for a $APPOINMENT_INFO_FORMATTED."
  fi 
}

SERVICE_MENU
