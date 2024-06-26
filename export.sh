#! /bin/bash

baseDir="dbfiles"

dockerName="systemone-postgresql"

start(){
	echo "Exporting data from docker "$dockerName
	docker exec  -i $dockerName bash < runInsideDocker.sh
	echo "Copying files to local export folder..."
	docker cp $dockerName:/$baseDir/systemOne ./$baseDir
}

start