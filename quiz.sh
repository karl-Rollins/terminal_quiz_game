#!/bin/bash

if [[ "$1" == "highscores" ]]; then
    echo "HIGH SCORES"
    if [[ -f "highscore.txt" ]]; then
        sort -t '|' -k2,2rn "highscore.txt" | head -n 5 
    fi
    exit 0
elif [[ "$1" == "practice" ]]; then
    PRACTICE=true
    echo " Practice Mode"
fi

Questions="./questions.txt"  

if [[ ! -f "$Questions" ]]; then
     echo "File is missing"
elif [[ ! -s "$Questions" ]]; then
    echo "File is empty"
fi 

read -rp "Enter User name: " username </dev/tty

TOTAL_COUNT=$(wc -l < questions.txt)
TOTAL_QUESTIONS=0
Correct_COUNT=0
Wrong_COUNT=0
STREAK=0
MAX_STREAK=0

while IFS= read -r line; do
    clear
    #to clear the screenREADME.md

    IFS='|' read -ra parts <<< "$line"
    #| is the delimeter. -a stores parts in arrays

    ((TOTAL_QUESTIONS++))
    FIRST_ATTEMPT=true

    echo "Question $TOTAL_QUESTIONS of $TOTAL_COUNT"
    echo "${parts[0]}"
    echo "${parts[1]}"
    echo "${parts[2]}"
    echo "${parts[3]}"
    echo "${parts[4]}"

    read -rp "Enter your answer (A/B/C/D): " ans </dev/tty
    ans=${ans^^}
    #ans^^ changes all the input to upper case.

    while true; do
        if [[ "$ans" != "A" && "$ans" != "B" && "$ans" != "C" && "$ans" != "D" ]]; then
            echo "Invalid Input. Enter either A,B,C,D."
            read -rp "Enter your answer (A/B/C/D): " ans </dev/tty
            ans=${ans^^}
        else
            break;
        fi
    done
      
    if [[ "$ans" == "${parts[5]}" ]]; then
            echo  -e "\e[32mCorrect!\e[0m"
            ((Correct_COUNT++))

            if [[ "$FIRST_ATTEMPT" == true ]]; then
                ((STREAK++))

                if [[ "$STREAK" -gt "$MAX_STREAK" ]]; then
                MAX_STREAK="$STREAK"
                fi

            fi
        
         
    elif [[ "$PRACTICE" == true ]]; then
        echo  -e "\e[31mWrong.The answer is ${parts[5]}\e[0m"
    else
        echo  -e "\e[31mWrong.The answer is ${parts[5]}\e[0m"
        ((Wrong_COUNT++))
        STREAK=0
        FIRST_ATTEMPT=false     
    fi

    sleep 2
    #read -rp "Press Enter to continue." </dev/tty
    #echo "answer: ${parts[5]}"
    echo ""

done < <(shuf $Questions)
# shuf: brings lines in random order
#/dev/tty forces the terminal to wait for user input

if [[ "$PRACTICE" ==  true ]];then 
    echo "Practice is over. Scores are not saved"
else 
    echo "Quiz finished"
    percentage=$(( Correct_COUNT * 100 / TOTAL_QUESTIONS   ))
    echo "Correct: $Correct_COUNT Incorrect: $Wrong_COUNT longest streak: $MAX_STREAK Final score: $percentage%"
    echo "$username | $percentage% | $Correct_COUNT/$TOTAL_QUESTIONS | $(date "+%Y-%m-%d")" >> highscore.txt
fi
