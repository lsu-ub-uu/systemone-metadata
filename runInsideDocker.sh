#! /bin/bash

baseDir="dbfiles"

database="systemone"
dataDividers="cora jsClient systemOne testSystem"

start(){
	echo "Running inside docker..."
	mkdir -p /$baseDir/
	exportAll;
}

exportAll(){
	for dataDivider in $dataDividers ; do
		echo "Exporting for dataDivider: " $dataDivider
		exportForDataDivider $dataDivider
	done
}

exportForDataDivider(){
	local dataDivider=$1
	mkdir -p /$baseDir/$dataDivider
	exportRecords $dataDivider
	exportLinks $dataDivider
	exportStorageTerms $dataDivider
}

exportRecords(){
	local dataDivider=$1
	local file="/"$baseDir"/"$dataDivider"/1_records.sql"
	local sql="select * from record where datadivider = '"$dataDivider"' order by type, id"

	echo "COPY public.record (type, id, datadivider, data) FROM stdin;" > $file
	runExport "$sql" "$file"
}
runExport(){
	local sql=$1
	local file=$2
	
	psql -h localhost -U $database -c "\copy (""$sql"") to PROGRAM 'cat >>"$file"'"
}

exportLinks(){
	local dataDivider=$1
	local file="/"$baseDir"/"$dataDivider"/2_links.sql"
	local sql="select l.* from link l join record r on l.fromtype = r.\"type\"  and l.fromid = r.id where datadivider = '"$dataDivider"' order by fromtype, fromid"

	echo "COPY public.link (fromtype, fromid, totype, toid) FROM stdin;" > $file
	runExport "$sql" "$file"
}
exportStorageTerms(){
	local dataDivider=$1
	local file="/"$baseDir"/"$dataDivider"/3_storageterms.sql"
	local sql="select recordtype, recordid, storagetermid, value, storagekey from storageterm s join record r on s.recordtype = r."type"  and s.recordid = r.id where datadivider = '"$dataDivider"' order by recordtype, recordid"

	echo "COPY public.storageterm (recordtype, recordid, storagetermid, value, storagekey) FROM stdin;" > $file
	runExport "$sql" "$file"
}

start