#!/bin/bash


FILE=~/.moulitoken
if test -f "$FILE"; then
    echo "Config file found"
else
	touch ~/.moulitoken	
fi

AUTH_TOKEN=$(cat ~/.moulitoken)


login() {
	data_row='{"username": "'
	data_row+=$1
	data_row+='", "password": "'
	data_row+=$2
	data_row+='"}'
	REQ_RESULT=$(curl -s --location 'https://tekme.eu/api/auth/login/bocal'	--header 'Content-Type: application/json' --data-raw "$data_row")
	echo $REQ_RESULT
	AUTH_TOKEN=$(echo "$REQ_RESULT" | jq ".token")
	AUTH_TOKEN=$(echo $AUTH_TOKEN | tr -d '"')
	echo $AUTH_TOKEN > ~/.moulitoken
}

if [[ "$1" == "login" ]] | [[ $AUTH_TOKEN == "" ]] | [[ $AUTH_TOKEN == "null" ]]
then
	echo -e "Entrez votre \e[36memail\e[97m Epitech: "
	read username
	echo "Entrez votre \e[36mmot de passe\e[97m Epitech: "
	read -s password
	login $username $password
fi


req_header='Authorization:'
req_header+=$AUTH_TOKEN
req_header+=''
feedback=$(curl -s --location 'https://tekme.eu/api/profile/moulinettes' --header $req_header)

# Script made by @Watersrc_stack (Github)

clear
echo "List of projects ids :"
printf "\n"

END=$(echo $feedback | jq ".jobs | length")
# echo $END
for ((N=0; N < $END; N++))
do
	# echo $N
	echo -e "	Id $N ->\e[92m" $(echo $feedback | jq ".jobs[$N].project" | tr -d '"')"\e[97m"

done

printf "\nProject id ? "
read pid


feedback=$(echo $feedback | jq ".jobs[$pid]")
login=$(echo $feedback | jq ".login" | tr -d '"' | tr '.' ' ')
trace=$(echo $feedback | jq ".trace")
LEN=$(echo $feedback | jq "length")
traceid=$(echo $feedback | jq ".id")
clear

if [[ $LEN -eq 0 ]]
then
	echo -e "\e[31m418 Moulinette not found :(\e[97m"
	exit 0
fi
bigtrace=$(curl https://tekme.eu/api/profile/moulinettes/$traceid/trace -H 'Accept: application/json' -H 'Authorization: DmyapVM3hkk2jbdtDVAoQItV9HxFUNWkxCPvU3Rgx726fewN46FkkoVrTnbBWkzE' | jq ".trace_pool")
clear

echo -e "Hello\e[94m" $login"\e[97m, Here are the results of the last Moulinette: "
echo -e "\e[36m"Project: $(echo $feedback | jq ".project" | tr -d '"')"\e[97m"
printf "\n"

passed=$(echo $trace | jq ".total_tests_passed")
total=$(echo $trace | jq ".total_tests")

testprc=$(echo $trace | jq ".total_tests_percentage" | cut -c -2)
testprc=$((testprc))

echo -n "	"Tests passed: $passed/$total "-- "
if [ $testprc -le 33 ]
then
	echo -e "\e[31m"$testprc%"\e[97m"
elif [ $testprc -le 66 ]
then
	echo -e "\e[33m"$testprc%"\e[97m"
else
	echo -e "\e[32m"$testprc%"\e[97m"
fi

failed=0
END=$(echo $trace | jq ".skills[0].tests[0] | length")
for ((N=0; N<=$END; N++))
do
	num=$(($N+1))
	pssd=$(echo $trace | jq ".skills[$N].tests[0].passed" | tr -d '"')
	if $pssd == true
	then
		echo -e "  \e[95m"Test$num"\e[97m" -- passed: "\e[32m"$pssd"\e[97m"  \|\|  comment: $(echo $trace | jq ".skills[$N].tests[0].comment" | tr -d '"')
	else
		failed=$((failed+1))

		echo -e "  \e[95m"Test$num"\e[97m" -- passed: "\e[31m"$pssd"\e[97m"  \|\|  comment: $(echo $trace | jq ".skills[$N].tests[0].comment" | tr -d '"')
	fi
	# echo -e "  \e[37m"Test$num"\e[97m" -- passed: $pssd  \|\|  comment: $(echo $trace | jq ".skills[$N].tests[0].comment" | tr -d '"')
done

if [ $failed -gt 0 ]
then
	printf "\n\n\n"
	echo "Press enter to see trace"
	read tmp
	echo Trace is :
	echo -e $bigtrace
fi
