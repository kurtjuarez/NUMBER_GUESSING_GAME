#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo "Enter your username:"
read USERNAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME';")
if [[ -z $USER_ID ]]
then
  echo "Welcome, $USERNAME! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME');"
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM games WHERE user_id=$USER_ID;")
  BEST_GAME=$($PSQL "SELECT best_game FROM games WHERE user_id=$USER_ID;")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
NUMBER_OF_GUESSES=0
echo "Guess the secret number between 1 and 1000:"
while true
do
  read NUMBER_GUESSED
  if [[ $NUMBER_GUESSED -gt $SECRET_NUMBER ]]
  then
    echo "It's lower than that, guess again:"
    (( NUMBER_OF_GUESSES+=1 ))
  elif [[ $NUMBER_GUESSED -lt $SECRET_NUMBER ]]
  then
    echo "It's higher than that, guess again:"
    (( NUMBER_OF_GUESSES+=1 ))
  elif [[ $NUMBER_GUESSED -eq $SECRET_NUMBER ]]
  then
  (( NUMBER_OF_GUESSES+=1 ))
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

    break
  else
    echo "That is not an integer, guess again:"
  fi
done