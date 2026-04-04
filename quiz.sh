#!/bin/bash

if [[ "$1" == "highscores" ]]; then
    echo "HIGH SCORES"
    if [[ -f "highscore.txt" ]]; then
        cat "highscore.txt" | head -n 5
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

read -p "Enter User name: " username </dev/tty

TOTAL_COUNT=$(wc -l < questions.txt)
TOTAL_QUESTIONS=0
Correct_COUNT=0
Wrong_COUNT=0
STREAK=0
MAX_STREAK=0

while IFS= read -r line; do
    clear
    #to clear the screen

    IFS='|' read -ra parts <<< "$line"
    #| is the delimeter. -a stores parts in arrays

    ((TOTAL_QUESTIONS++))
    FIRST_ATTEMPT=true

    echo "Question $TOTAL_QUESTIONS of $TOTAL_COUNT"
    echo "question_text: ${parts[0]}"
    echo "option_a: ${parts[1]}"
    echo "option_b: ${parts[2]}"
    echo "option_c: ${parts[3]}"
    echo "option_d: ${parts[4]}"

    until [[ "$ans" == "${parts[5]}" ]]; do
        read -p "Enter your answer (A/B/C/D): " ans </dev/tty
        ans=${ans^^}
        #ans^^ changes all the input to upper case. 

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
                echo "Incorrect. the correct answer was ${parts[5]}"
        else
            echo  -e "\e[31mWrong. Try again\e[0m"
            ((Wrong_COUNT++))
            STREAK=0
            FIRST_ATTEMPT=false
            
        fi
    done

    read -p "Press Enter to continue." </dev/tty
    #echo "answer: ${parts[5]}"
    echo ""

done < <(shuf $Questions)
# shuf: brings lines in random order
#/dev/tty forces the terminal to wait for user input

if [[ "$PRACTICE" ==  true ]];then 
    echo "Practice is over. Scores are not saved"
else 
    echo "Quiz finished"
    percentage=$(( (Correct_COUNT * 100) / TOTAL_QUESTIONS ))
    echo "Correct: $Correct_COUNT Incorrect: $Wrong_COUNT longest streak: $MAX_STREAK Final score: $percentage%"
    echo "$username | $percentage% | $Correct_COUNT/$TOTAL_QUESTIONS | $(date "+%Y-%m-%d")" >> highscore.txt
fi
