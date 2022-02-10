#! /usr/bin/env bash

# Machine specifc parameters
HOST="$(hostname -I | cut -d' ' -f1)"
PSQLPASS="vmturbo"

# Test specific commands
INPUT="true"
DELETE_DUPLICATES_KEEP="min"

# Basic command line interface to pass arguments #
##################################################

usage="$(basename "$0") [OPTIONS] -- Basic script to clean the scope table.

OPTIONS:
    -h| --help                      show this help text
    -p| --pass ARG                  the psql password
    --host ARG                      the psql host to connect
    -y| --no-input                  if set will not ask for verification to run the query
    --time ARG                      Time until to delete stuff
    --select-duplicates             Returns a list of duplicates with limit 10
    --count-duplicates              Counts duplicates
    --delete-duplicates             Delete all duplicates leaving the min start (only active rows)
    --count-business-transaction    Count all scope with type 'BUSINESS_TRANSACTION'
    --delete-business-transaction   Delete all business transaction for both scope and entity, and update indexes
    --latest                        Delete duplicates will keep the max start instead of the min
"

CMD=""
while [[ $1 != "" ]]; do
    case "$1" in
    -p|--pass)
        shift
        if [[ "$1" != "" ]]; then
            PSQLPASS="$1"
            shift
        else
            "-p|--pass does not have an argument"
            echo $usage
            exit 1
        fi
        ;;
    --host)
        shift
        if [[ "$1" != "" ]]; then
            HOST="$1"
            shift
        else
            "--host does not have an argument"
            echo -e "$usage"
            exit 1
        fi
        ;;
    -y|--no-input)
        shift
        INPUT="false"
        ;;
    --select-duplicates)
        shift
        CMD="SELECT_DUPLICATES"
        ;;
    --count-duplicates)
        shift
        CMD="COUNT_DUPLICATES"
        ;;
    --delete-duplicates)
        shift
        CMD="DELETE_DUPLICATES"
        ;;
    --count-business-transaction)
        shift
        CMD="COUNT_BUSINESS_TRANSACTION"
        ;;
    --delete-business-transaction)
        shift
        CMD="DELETE_BUSINESS_TRANSACTION"
        ;;
    --time)
        shift
        if [[ "$1" != "" ]]; then
            TIME="$1"
            shift
        else
            "--time does not have an argument"
            echo -e "$usage"
            exit 1
        fi
        ;;
    --latest)
        shift
        DELETE_DUPLICATES_KEEP="max"
        ;;
    -h|--help)
        shift
        echo -e "$usage"
        exit 0
        ;;
    *)
        echo -e "$usage"
        exit 1
        ;;
    esac
done

# Basic functions #
###################

psql_command () {
    COMMAND="$1"
    if [[ $INPUT == "true" ]]; then
        read -e -p "The query to run is '$COMMAND'. Do you want to continue? [y/N] " response
        case "$response" in
        [yY][eE][sS]|[yY])
            ;;
        *)
            RUN="false"
            ;;
        esac
    fi

    if [[ $RUN == "false" ]]; then
        echo "Skipping..."
        return 0
    fi
    echo "Running query '$COMMAND'"

    PGPASSWORD=$PSQLPASS psql -Uextractor -w -h "$HOST" --command="$COMMAND"
}

selectScope() {
    psql_command "SELECT * FROM scope WHERE finish >= '9999-12-31 00:00:00' limit 2"
}

deleteDuplicates() {
    read -r -d '' PSQL_COMMAND << EOM
DELETE FROM scope WHERE finish >= '9999-12-31 00:00:00' 
AND (seed_oid, scoped_oid, scoped_type) IN (
    SELECT seed_oid, scoped_oid, scoped_type FROM scope WHERE
        finish >= '9999-12-31 00:00:00' GROUP BY seed_oid, scoped_oid, scoped_type HAVING count(*) > 1
    )
AND (seed_oid, scoped_oid, scoped_type, start) NOT IN (
    SELECT seed_oid, scoped_oid, scoped_type, $DELETE_DUPLICATES_KEEP(start) as start FROM scope WHERE 
        finish >= '9999-12-31 00:00:00' GROUP BY seed_oid, scoped_oid, scoped_type HAVING count(*) > 1
    )
;
EOM
    psql_command "$PSQL_COMMAND"
}

selectDuplicates() {
    psql_command "SELECT seed_oid, scoped_oid, scoped_type, count(*) AS dupe_count FROM scope WHERE finish >= '9999-12-31 00:00:00' GROUP BY seed_oid, scoped_oid, scoped_type HAVING count(*) > 1 limit 10"
}

countDuplicates() {
    psql_command "SELECT count(*) FROM (SELECT count(*) AS dupe_count FROM scope WHERE finish >= '9999-12-31 00:00:00' GROUP BY seed_oid, scoped_oid, scoped_type HAVING count(*) > 1) as duplicate_rows;"
}

countBusinessTransaction() {
    psql_command "SELECT count(*) FROM scope WHERE scoped_type = 'BUSINESS_TRANSACTION';"
}

deleteBusinessTransaction() {
    set +e
    # psql_command "DELETE FROM scope where scoped_type = 'BUSINESS_TRANSACTION' and finish < '9999-12-31 00:00:00'"
    psql_command "DROP INDEX scope_seed_type_start;"
    psql_command "ALTER TABLE scope DROP CONSTRAINT scope_pkey1;"
    psql_command "BEGIN; DELETE FROM scope where scoped_type = 'BUSINESS_TRANSACTION'; DELETE FROM scope USING entity where scope.seed_oid = entity.oid and type = 'BUSINESS_TRANSACTION'; COMMIT;"
    psql_command "VACUUM FULL scope;"
    psql_command "CREATE INDEX scope_seed_type_start ON scope (seed_oid, scoped_type, start);"
    psql_command "ALTER TABLE scope ADD PRIMARY KEY (seed_oid, scoped_oid, start);"
    set -e
}

if [[ $CMD == "" ]]; then
    selectScope
fi

if [[ $CMD == "SELECT_DUPLICATES" ]]; then
    selectDuplicates
fi

if [[ $CMD == "COUNT_DUPLICATES" ]]; then
    countDuplicates
fi

if [[ $CMD == "DELETE_DUPLICATES" ]]; then
    deleteDuplicates
    if [[ "$?" != "0" ]]; then
        echo "Deleting duplicates failed"
        return $?
    fi
    echo "Done with DELETE_DUPLICATES"
fi

if [[ $CMD == "COUNT_BUSINESS_TRANSACTION" ]]; then
    countBusinessTransaction
fi

if [[ $CMD == "DELETE_BUSINESS_TRANSACTION" ]]; then
    deleteBusinessTransaction
    if [[ "$?" != "0" ]]; then
        echo "Deleting business transaction failed"
        return $?
    fi
    echo "Done with DELETE_BUSINESS_TRANSACTION"
fi
