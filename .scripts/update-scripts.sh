DIR=`pwd`/`dirname $BASH_SOURCE`
echo "copying *.js .scripts from $DIR to project .scripts folders"
cp $DIR/*.js  $DIR/../autorest/.scripts
cp $DIR/*.js  $DIR/../autorest.powershell/.scripts
cp $DIR/*.js  $DIR/../autorest.remodeler/.scripts
cp $DIR/*.js  $DIR/../perks/.scripts