#!/bin/bash
export PGPASSWORD=postgres
readonly cb_name=$1
readonly role=$2
readonly scope=$3

# sleep 3 seconds in case that postgres is not ready
sleep 3

function usage() {
    echo "Usage: $0 <on_start|on_role_change> <role> <scope>";
    exit 1;
}

echo "this is patroni callback $cb_name $role $scope"
create_table="
    CREATE TABLE IF NOT EXISTS current_master(
        id serial PRIMARY KEY,
        hostname text
    );
"
insert_record="
    INSERT INTO current_master (hostname) VALUES ('$HOSTNAME');
"

case $cb_name in
    on_start)
        if [[ $role == 'master' ]]; then
            psql -h localhost -U postgres -d postgres -c "${create_table}";
            psql -h localhost -U postgres -d postgres -c "${insert_record}";
        fi
        ;;
    on_role_change)
        if [[ $role == 'master' ]]; then
            psql -h localhost -U postgres -d postgres -c "${insert_record}";
        fi
        ;; 
    *)
        usage
        ;;
esac