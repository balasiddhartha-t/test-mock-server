startGraphQL () {
	port=$1
	echo "Hello $port"
	open=`netstat -ano | findstr ":$port"`
	echo $open
	if [ -z "$open" ];
	then
		echo "$port"
		echo "NOT IN USE";
		echo "Pulling docker images";
		docker pull apisguru/graphql-faker
		docker run -p=$port:9002 apisguru/graphql-faker -- schema.graphql
		echo "The operation is completed"
		echo "You can now start hacking the machines at port $port"
		
	else
		echo "Port is in USE";
		echo "Looking for next available port"
		port=$((port+1))	
		startGraphQL $port
	fi

}


startRest () {
	port=$1
	open=`netstat -ano | findstr ":$port"`
	echo $open
	if [ -z "$open" ];
	then
		echo "$port"
		echo "NOT IN USE";
		echo "Pulling docker images";
		docker pull mockserver/mockserver
		docker run -d --rm -p $port:1080 mockserver/mockserver -serverPort 1080
		curl -v -X PUT "http://localhost:$port/mockserver/expectation" -d @schema.json \
		--header "Content-Type: application/json"
		echo "The operation is completed"
		echo "You can now start hacking the machines at port $port"
	else
		echo "Port is in USE";
		echo "Looking for next available port"
		port=$((port+1))	
		startRest $port
	fi

}



echo "Please choose one of the servers to mock"
echo "1. GraphQL"
echo "2. REST"
read name


if [ $name == '1' ] || [ $name == 'graphql'  ] 
then
	echo "Please choose a name from the below listed folders: "
	cd  graphql/	
	select FILENAME in */;	
	do
     echo "You picked $FILENAME ($REPLY)."
     echo "Creating Docker file for the Selected configuration"
	 if [ ! -d "$FILENAME" ]
		then
			echo "Directory DOES NOT exists."
			echo "Please make sure that you selected the correct option"
		else
			cd $FILENAME
			echo $PWD
			startGraphQL "9002"
			break
		fi
	done
	
	
elif [ $name == '2' ] || [ $name == 'rest' ] 
then 
	echo "Please choose a name from the below listed folders: "
	cd rest/
	select FILENAME in */;	
	do
     echo "You picked $FILENAME ($REPLY)."
	 if [ ! -d "$FILENAME" ]
		then
			echo "Directory DOES NOT exists."
			echo "Please make sure that you selected the correct option"
		else
			cd $FILENAME
			echo "Creating Docker file for the Selected configuration"
			echo $PWD
			startRest "1080"
			break
		fi
	done
else
	echo "Please pick from either of the two (Enter 1 or 2)"
fi








