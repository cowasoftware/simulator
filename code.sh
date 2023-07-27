
TOTAL_LINE=0
declare -A myhashtable

souece_files=`find .  ! -path "./build/*" -regex ".*\(\.cpp\|\.cc\|\.h\|\.qml\|\.go\)$"`
for file in $souece_files  
do  
    if expr "$file" : '.*\.pb\.*' &>/dev/null
    then
        # echo $file
        continue
    fi
    # wc -l $file
    content=`git blame -n $file  | awk -F '(' '{print $2}' | awk '{print $1}'`
    line_num=0
    for name in $content;
    do
        [[ $name == " " ||  $name == "" ]] && continue  
        [[ ${myhashtable[$name]} == " " ||  ${myhashtable[$name]} == "" ]] && myhashtable[$name]=0 && continue
        count=${myhashtable[$name]}
        let count++
        myhashtable[$name]=$count

        let line_num++
    done
    TOTAL_LINE=`expr $TOTAL_LINE + $line_num`

done



for key in "${!myhashtable[@]}";
do
    echo "$key  -> ${myhashtable[$key]}"
done

echo "total " $TOTAL_LINE