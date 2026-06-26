#!/bin/sh

set -ex

until mongosh --host auth-db:27017 --eval "db.adminCommand('ping')"
do
    echo "Waiting Mongo..."
    sleep 2
done

echo "Mongo ready"

mongosh --host auth-db:27017 --eval '
rs.initiate({
    _id:"rs0",
    members:[
        {
            _id:0,
            host:"auth-db:27017"
        }
    ]
})
'

echo "Finished"