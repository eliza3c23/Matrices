#!/bin/bash
#Jan-18-2019
#CS 344 Assignment 1- Matrix
#Eliza Nip (nipe@oregonstate.edu)
#------------------------------------------
#Note to myself:
# man - A program to explain commands.
# man man - To see the general syntax of man pages.
# "$#" = Stores num of command-line arguments that were passed to the program.
# expr = evaluate expression
# `expr $i+1 is same as $(expr $i+1) : Both do command subsitution with subshells
#1>&2 # Redirects stdout to stderr
#col =$(($(head -n 1 "$1" | tr '\t' '\n' | wc -l)))
#!!!!!!sc is case sensitive!!!!!!
#-------------------------------------------

#Helper function that get rows and columns from file
readMf()
{
 declare -A matrix1   
 row=0
 col=0
 while read mf          #Read each line in mf
 do
    col=0
    for i in $mf        
    do
        matrix1[$row,$col]=$i     #Create a matrix
        col=$((col + 1))
    done
    row=$((row + 1))
 done < $1 
}

#Calculate dimensions
#Use readMf() to get rows and columns from file
#Print out result. *Printf faster than echo?*
dims()
{ 
    #The only function that my readMf() works
    readMf $1
    printf "$row $col\n"

}
#Transpose
#Transpose matrices
transpose()
{
  #Transpose method taught by "The Linux Rain"
  col=$(($(head -n 1 "$1" | wc -w)))
  for (( a=1; a<="$col"; a++ ))
  do
    cut -f"$a" "$1" | paste -s
  done
}

#Calculate matrix mean
mean()
{
  #readMf() does not work in any function other than dims(), so I rewrote the parts in readMf into mean()
  declare -A matrix1   
  row=0
  col=0
  sum=0
  mean=0
  x=0
  while read mf          #Read each line in mf
  do
    col=0
    for i in $mf        
    do
        matrix1[$row,$col]=$i     #Create a matrix
        col=$((col + 1))
    done
    row=$((row + 1))
  done < $1 
  #Loop through col
  for ((a=0;a<col;a++))
  do
    sum=0
    mean=0
    #Loop through row
	for ((b=0;b<row;b++))
	do
	    x=${matrix1[$b,$a]}     
        sum=$(( $sum + $x ))	
	done	
		#From the hit rounding formula (a + (b/2)*( (a>0)*2-1 )) / b	
	mean=$(( ($sum + ($row/2) * ( ($sum>0)*2-1 )) / $row ))
	if [ "$a" == "$((col - 1))" ]
	then
	    echo -n "$mean"
		else
		    echo -n "$mean	"
	fi
    done
echo
}

#Add two matrices
#Check their dimensions first, make sure these two matrices have same dimensions.
#Print the result
add()
{
    #I looked up how to tranpose rows and columns on "The Linux Rain". 
    #I edited the example on the site to fit in to my add().
    row1=$(($(cat "$1" | wc -l)))
    col1=$(($(head -n 1 "$1" | tr '\t' '\n' | wc -l)))
    
    row2=$(($(cat "$2" | wc -l)))
    col2=$(($(head -n 1 "$2" | tr '\t' '\n' | wc -l)))

    if [ $row1 != $row2 ] || [ $col1 != $col2 ] #Check if 2 matrices have same dimensions
    then
        printf "Error: Invalid demension, can not perform addition.\n" 1>&2
        exit 1
    else
        #Learnt from tldp.org, the bash-scripting guide.
        mx1=( `cat "$1" `) #Load contents from f1
        mx2=( `cat "$2" `) #Load contens from f2
        mxTotal=${#mx1[@]} 
        i=0
        while [ $i -lt $mxTotal ]
        do
            sum=$(( ${mx1[i]} + ${mx2[i]} ))
            echo -n $sum
            if [ $(( ($i + 1) % $col1 )) != 0 ]
            then
                echo -ne '\t'
            else
                echo 
            fi
            ((i++))
        done
    fi
    

}

#Multiply two matrices
#Get two matrices
#Check both dimensions, make sure they have the same dimensions, otherwise task could not be performed.
multiply()
{
    #My readmf function does not work on function other than dims(), so I rewrote the readmf() part in multiply function.
    #I declared two because this function needs two. 
    product=0
    declare -A matrix1  
    declare -A matrix2 
    row1=0
    col1=0
    sum=0
    x=0
    while read mf          #Read each line in mf
    do
        col1=0
        for i in $mf        
        do
            matrix1[$row1,$col1]=$i     #Create a matrix
            col1=$((col1 + 1))
        done
        row1=$((row1 + 1))
  done < $1 
    row2=0
    col2=0
    
    while read mf2
    do
        col2=0
        for t in $mf2
        do
            matrix2[$row2,$col2]=$t   #Create another matrix
            col2=$(( col2 + 1 ))
        done
        row2=$(( row2 + 1 ))
    done < $2

    #Check if col1 = row2 (MUST FOR MUL)
    if [ $col1 != $row2 ]                                                       #Check if 2 matrices have same dimensions
    then
        printf "Error: Invalid demension, can not perform addition.\n" 1>&2
        exit 1
    else                                            
        for ((a=0;a<row1;a++))
        do
            for ((b=0;b<col2;b++))
            do
                product=0
                finalProduct=0
                for ((c=0;c<col1;c++)) 
                do
                    mul1=${matrix1[$a,$c]}                          #Return stores in mul1 
                    mul2=${matrix2[$c,$b]}                          #Return stores in mul2
                    product=$(($mul1 * $mul2))                      
                    finalProduct=$(( $finalProduct + $product ))
                done
                if [ "$b" == "$(($col2 - 1))" ]
			then
				echo -n "$finalProduct"
			else
				echo -n "$finalProduct	"
			fi
            done
            echo
        done
    fi
}
########################################################################################################################
########################################################################################################################
#Main
#Check arguments, based on which function is called.
if [ "$1" == "dims" ] || [ "$1" == "transpose" ] || [ "$1" == "mean" ]
then	
	stdin="${2:-/dev/stdin}"       #stdin or input from user. This part is learnt from jameshfisher.com.(/dev/stdout,/dev/stdin) 
	
	if test "$3"                   #Check if number of file is validated for these functions. They need 1
	then
		echo "Error: Invalid number of file" 1>&2   
		exit 1
	elif ! [ -r $2 ]               #Check if file is readable
	then
		echo "Error: Unable to read file" 1>&2
		exit 1
	else
		$1 $stdin                  #If passes above conditions, good to go.
	fi
elif [ "$1" == "add" ] || [ "$1" == "multiply" ]
then
	if (($# == 1)) || test "$4"    #Check if number of file is validated for these function. They need 2.
	then
		echo "Error: Invalid number of file " 1>&2
		exit 1
	elif ! [ -r $2 ] || ! [ -r $3 ] #Check if both files are readable. For add and multiply, we need 2.
	then
		echo "Error: Unable to read file" 1>&2
		exit 1
	else
		$1 $2 $3
	fi
else
	echo "Error: No such function" 1>&2    #If bs is entered, other than existed function, show error message.
	exit 1
fi