#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~Welcom~~\n"


MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

 SERVICE_LIST=$($PSQL "select service_id,name from services")
  if [[ -z $SERVICE_LIST ]]
  then
    echo "The shop is currently closed. Thank you for stopping in."
  else
    echo "$SERVICE_LIST" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done
  fi

  echo "Please enter the service you would like:"
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ ^[1-5]$ ]]
  then
    MAIN_MENU "This is not a valide option."
  else
    echo "Please enter your phone number:"
    read CUSTOMER_PHONE
    CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_NAME ]]
    then
      echo "What's your name?"
      read CUSTOMER_NAME
      #insert new customer
      INSERT_NEW_CUSTOMER=$($PSQL "insert into customers(phone, name) values('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      echo "Welcome $CUSTOMER_NAME, please enter the time you want to book:"
      read SERVICE_TIME

      SERVICE_BOOKING=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      
      SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
      echo "I have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
    else
      # get customer id
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE'")
      echo "Welcome $CUSTOMER_NAME, please enter the time you want to book:"
      read SERVICE_TIME

      SERVICE_BOOKING=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
      
      SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")
      echo "I have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $CUSTOMER_NAME."
    fi
  fi  

}

MAIN_MENU