#!/bin/bash

FILE_TO_EDIT="name-of-file"
SEARCH_USERNAME_STRING="string-to-be-replaced"
REPLACE_USERNAME_STRING="string-to-replace-with"
SEARCH_PASS_STRING="string-to-be-replaced"
REPLACE_PASS_STRING="string-to-replace-with"

SITES_DIR=/var/www/*sites*/

for d in $SITES_DIR; do
    if [[ -d $d/html ]]
    then
	    echo "Dir named html exists, going to check if ${FILE_TO_EDIT} exists!"

            if [[ -f $d/html/${FILE_TO_EDIT} ]]
            then
	            echo "${FILE_TO_EDIT} exits, going to replace required string!"
	      
	      	    if grep -Fxq ${SEARCH_USERNAME_STRING} $d/html/${FILE_TO_EDIT};
	            then
                
                    if (sed -i "s|$SEARCH_USERNAME_STRING|$REPLACE_USERNAME_STRING|g" $d/html/${FILE_TO_EDIT})
                    then
             	        echo "DB username replaced in ${FILE_TO_EDIT} for $d site"
		  		        cat $d/html/${FILE_TO_EDIT}
	      		    else
		 		        echo "Can't replace DB username for $d site"
	                fi
	            
                else
             	    echo "Couldn't find the string we want to replace"
             
			    if grep -Fxq ${SEARCH_PASS_STRING} $d/html/${FILE_TO_EDIT};
	   		    then
	      	        echo "Need to replacing password string in $d"
	      	        if (sed -i "s|$SEARCH_PASS_STRING|$REPLACE_PASS_STRING|g" $d/html/${FILE_TO_EDIT})
	      	        then
		 	            echo "DB password replaced in ${FILE_TO_EDIT} for $d site"
		 	            cat $d/html/${FILE_TO_EDIT}
	                else
	                    echo "Can't replace DB pass for $d site"
	                fi
	           
	   		    else
	   		        echo "Password already repalced in $d"
	   		    fi

            else
       	        echo "Can't find file we want to edit in $d"
            fi
            
    else
       echo "Can't find directory named html in $d"
    fi

done
