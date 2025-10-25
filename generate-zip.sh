#!/usr/bin/env bash

#
#   Generate zip from a Disembark backup of WordPress
#
#   `generate-zip --url=<url> --token=<token> --backup-token=<backup-token>`
#
#   [--cleanup]
#   Removes related backup files after zip is downloaded
#

# Loop through arguments and separate regular arguments from flags
for arg in "$@"; do

  # Add to arguments array. (Does not starts with "--")
  if [[ $arg != --* ]]; then
    count=1+${#arguments[*]}
    arguments[$count]=$arg
    continue
  fi

  # Remove leading "--"
  flag_name=$( echo $arg | cut -c 3- )

  # Add to flags array
  count=1+${#flags[*]}
  flags[$count]=$arg

  # Process flags without data (Assign to variable)
  if [[ $arg != *"="* ]]; then
    flag_name=${flag_name//-/_}
    declare "$flag_name"=true
  fi

  # Process flags with data (Assign to variable)
  if [[ $arg == *"="* ]]; then
    flag_value=$( echo $flag_name | perl -n -e '/.+?=(.+)/&& print $1' ) # extract value
    flag_name=$( echo $flag_name | perl -n -e '/(.+?)=.+/&& print $1' ) # extract name
    flag_name=${flag_name/-/_}

    # Remove first and last quote if found
    flag_value="${flag_value%\"}"
    flag_value="${flag_value#\"}"

    declare "$flag_name"="$flag_value"
    continue
  fi

done

read -r -d '' php_code << heredoc
\$arguments = <<<PHPHEREDOC
$url
PHPHEREDOC;
echo urldecode( \$arguments );
heredoc

url=$( php -r "$php_code" )
domain=${url/http:\/\/www./}     # removes http://www.
domain=${domain/https:\/\/www./} # removes https://www.
domain=${domain/http:\/\//}      # removes https://
domain=${domain/https:\/\//}     # removes http://
domain=${domain//\//_}           # replaces / with _

# Store current path
home_directory=$(pwd)

run_command() {
    temp_directory="snapshot-$(date +%s)"
    if [ -d "$temp_directory" ]; then
        echo "Unable to create temporary directory $temp_directory as it already exists."
        exit
    fi
    mkdir $temp_directory
    cd $temp_directory
    files=$( curl --insecure -sX GET "$url/wp-json/disembark/v1/download?token=$token&backup_token=$backup_token" )
    if [[ "$files" == "" ]]; then 
        echo "No files found. Check your URL and token."
        return
    fi
    for file in ${files}; do
        echo "Downloading $file to $temp_directory"
        curl --insecure -# -O $file
    done
    mkdir public
    mkdir database
    if ls *.sql 1> /dev/null 2>&1; then
      mv *.sql database/
    fi

    # Unzip files
    if ls files-*.zip 1> /dev/null 2>&1; then
      for file in $(ls files-*.zip | sort -V); do
          echo "Extracting from $file"
          unzip -q $file -d public/
      done
    fi

    # Prepare database file
    echo '/*!40101 SET NAMES utf8 */;' > public/database-$temp_directory.sql
    echo "SET sql_mode='NO_AUTO_VALUE_ON_ZERO';" >> public/database-$temp_directory.sql

    if [ -f "database.zip" ]; then
      unzip -q database.zip -d database/
    fi
  
    if ls database/*.sql 1> /dev/null 2>&1; then
      cat $(ls database/*.sql | sort -V) >> public/database-$temp_directory.sql
    fi
    echo "Generating $temp_directory-$domain.zip"
    zip -qr $temp_directory-$domain.zip public
    mv $temp_directory-$domain.zip ../
    cd ..
    if [ -d "$temp_directory" ]; then
        rm -rf "$temp_directory"
    fi
    if [[ "$cleanup" == "true" ]]; then
        echo "Cleaning up Disembark backups on $url"
        curl --insecure -sX GET "$url/wp-json/disembark/v1/cleanup?token=$token"
    fi
    echo ""
    echo "$temp_directory-$domain.zip is ready"
}
run_command