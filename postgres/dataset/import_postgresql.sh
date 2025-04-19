hostname=$1
port=$2
username=$3
database=$4
echo "Started importing data to PostgreSQL"
echo $(date '+%Y-%m-%d %H:%M:%S')
for dir in /docker-entrypoint-initdb.d/dataset/*/; do
  (
    folder_name=$(basename "$dir")

    echo "Processing $folder_name"

    # Change to the folder
    cd "$dir" || { echo "Failed to change directory to $dir"; exit 1; }
    ls *.csv.gz | xargs -n1 -P0 gzip -dfk
    ls *.csv | xargs -n1 -P0 sed -i 's/\"NULL\"/NULL/g'
    ls *.csv | xargs -I {} -n1 -P0 psql postgresql://$username@$hostname:$port/$database -c "\copy ${folder_name%/} FROM '{}' (FORMAT CSV, DELIMITER ',', NULL 'NULL', HEADER True, QUOTE '\"', ENCODING 'UTF8');"
    psql postgresql://$username@$hostname:$port/$database -f "db_import_${folder_name%/}_postgresql.sql"
  )
done
echo "Finished importing data to PostgreSQL"
echo $(date '+%Y-%m-%d %H:%M:%S')
