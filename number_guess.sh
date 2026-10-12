#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -q -c"
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))
echo "Enter your username:"
read USERNAME_INPUT
USERNAME=$($PSQL "SELECT username FROM users WHERE username='$USERNAME_INPUT';")
if [[ -z $USERNAME ]]
then
  echo "Welcome, $USERNAME_INPUT! It looks like this is your first time here."
  $PSQL "INSERT INTO users(username) VALUES('$USERNAME_INPUT');"
else
  GAMES_PLAYED=$($PSQL "SELECT COUNT(*) AS total_number_of_games FROM games INNER JOIN users USING(user_id) WHERE users.username='$USERNAME';")
  BEST_GAME=$($PSQL "SELECT MIN(number_of_guesses) AS fewest_number_of_guesses FROM games INNER JOIN users USING(user_id) WHERE users.username='$USERNAME';")

  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi
USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME_INPUT';")
NUMBER_OF_GUESSES=0
echo "Guess the secret number between 1 and 1000:"
while true
do
  read GUESS_INPUT
  if [[ ! $GUESS_INPUT =~ ^[0-9]+$ ]]
  then
    (( NUMBER_OF_GUESSES += 1 ))
    echo "That is not an integer, guess again:"
    continue
  elif [[ $GUESS_INPUT -gt $SECRET_NUMBER ]]
  then
    (( NUMBER_OF_GUESSES += 1 ))
    echo "It's lower than that, guess again:"
    continue
  elif [[ $GUESS_INPUT -lt $SECRET_NUMBER ]]
  then
    (( NUMBER_OF_GUESSES += 1 ))
    echo "It's higher than that, guess again:"
    continue
  else
    (( NUMBER_OF_GUESSES += 1 ))
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    $PSQL "INSERT INTO games(user_id, number_of_guesses) VALUES($USER_ID, $NUMBER_OF_GUESSES);"
    break
  fi
done