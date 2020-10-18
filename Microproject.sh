#! /bin/bash
FILE_PATH="Input.csv"
RESULT="./Result.csv"
#RES = Result.csv
printf "NAME," > $RESULT
printf "EMAIL," >> $RESULT
printf "GIT-URL," >> $RESULT
printf "Git-Clone-Status," >> $RESULT
printf "Build-status," >> $RESULT
printf "Cppcheck," >> $RESULT
printf "Valgrind\n" >> $RESULT

OLDIFS=$IFS
IFS=","
valgr=1
while read Name Email Repo
do
    [[ "$Name" != "Name" ]] && printf "$Name", >> $RESULT
    [[ "$Email" != "Email ID" ]] && printf "$Email", >> $RESULT
    [[ "$Repo" != "Repo link" ]] && printf "$Repo", >> $RESULT
    [[ "$Repo" != "Repo link" ]] && git clone $Repo
    if [ $? -eq 0 ] 
    then
        printf "Success", >> $RESULT 
        echo " Clone Success"
        navfold=`echo ="$Repo" | cut -d'/' -f5`
        echo "$navfold"
        makfold=`find ./"$navfold" -name "Makefile" -exec dirname {} \;`
        #echo "$makfold"
        if [ $makfold ]
        then 
            make -C "$makfold"
            if [ $? -eq 0 ];then
                printf "Success", >> $RESULT
            else
                printf "Failed", >> $RESULT
                valgr=0
            fi        
        else
            printf "Failed", >> $RESULT
            valgr=0
        fi
        #make -C "$makfold"
    elif [[ "$Repo" != "Repo link" ]]
    then
        printf "Failed", >> $RESULT
        printf "Failed", >> $RESULT
        printf "Failed", >> $RESULT
        printf "Failed\n" >> $RESULT        
        echo "Failed"
    fi
    cppcheck "$makfold"
    if [[ $? -eq 0 && "$Name" != "Name" ]];
    then
        printf "Success", >> $RESULT
    elif [[ "$Name" != "Name" ]]
    then
        printf "Failed", >> $RESULT
    fi    
    if [[ $valgr -ne 0 && "$Name" != "Name" ]]
    then
        chmod +x "$makfold"/*.out && valgrind "$makfold"/*.out 2>> valfile.txt
        valsuc=`tail -n 1 valfile.txt| cut -d ":" -f2 | cut -b 2`
        printf "$valsuc\n" >> $RESULT
    elif [[ "$Name" != "Name" ]]
    then
        printf "Failed\n" >> $RESULT
    fi
done <"${FILE_PATH}"