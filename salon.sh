#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"
SERVICE_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  else
    echo -e "\n~~~ SERVICE MENU ~~~\n "
  fi
  

  services=$($PSQL "SELECT service_id,name FROM services")
  echo "$services" | while read SERVICE_NUMBER BAR SERVICE
  do
    echo "$SERVICE_NUMBER) $SERVICE"
  done
  echo -e "\nGood day, What service would you like to purchase?"
  read SERVICE_ID_SELECTED
  # If service number doesn't exist
  SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id=$SERVICE_ID_SELECTED")
  if [[ -z $SERVICE_ID_SELECTED ]]
  then
    SERVICE_MENU "Please enter a service number that exists:"
  else
    echo -e "\nHello Customer, please enter your phone number"
    read CUSTOMER_PHONE
    CUSTOMER_PHONE_EXISTS=$($PSQL "SELECT phone FROM customers WHERE phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_PHONE_EXISTS ]]
    then
      echo -e "\nHello new customer, please input your name."
      read CUSTOMER_NAME
      echo -e "\nPlease enter the service time"
      read SERVICE_TIME
      NEW_CUSTOMER_INSERT=$($PSQL "INSERT INTO customers(phone,name) VALUES('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      CUSTOMER_ID_QUERY=$($PSQL "SELECT customer_id FROM customers where phone='$CUSTOMER_PHONE'")
      SERVICE_NAME_QUERY=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      APPOINTMENT_INSERT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID_QUERY,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      echo "I have put you down for $SERVICE_NAME_QUERY at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      CUSTOMER_NAME_QUERY=$($PSQL "SELECT name FROM customers where phone='$CUSTOMER_PHONE'")
      CUSTOMER_ID_QUERY=$($PSQL "SELECT customer_id FROM customers where phone='$CUSTOMER_PHONE'")
      SERVICE_NAME_QUERY=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED")
      echo -e "\nWhat time would you like your $SERVICE_NAME_QUERY, $CUSTOMER_NAME_QUERY?"
      read SERVICE_TIME
      APPOINTMENT_INSERT=$($PSQL "INSERT INTO appointments(customer_id,service_id,time) VALUES($CUSTOMER_ID_QUERY,$SERVICE_ID_SELECTED,'$SERVICE_TIME')")
      echo "I have put you down for $SERVICE_NAME_QUERY at $SERVICE_TIME, $CUSTOMER_NAME_QUERY."    
    fi
  fi
  
}

SERVICE_MENU
