#! /bin/bash

if [ ! -d $1 ]
then
	mkdir $1
fi

script_location=$( dirname -- "$0"; )

cp $script_location/i01-simulatedAnnealing.sh $1
cp -r $script_location/inputStream $1
