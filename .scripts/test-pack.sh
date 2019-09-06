# places
SCRIPT_FOLDER=`pwd`/`dirname $BASH_SOURCE`
REPO_FOLDER=`readlink -f $SCRIPT_FOLDER/..`
TEMP_FOLDER=`readlink -f $REPO_FOLDER/common/temp`

pushd $REPO_FOLDER

# clean out packages first
rm -rf  ~/.local/share/verdaccio/storage/@autorest/
rm -rf  ~/.local/share/verdaccio/storage/@azure-tools/
rm -rf  ~/.local/share/verdaccio/storage/autorest/

# and clean out previous artifacts
rm $REPO_FOLDER/common/temp/artifacts/packages/*.tgz 

# set patch version numbers 
rush set-versions

# create common/temp links 
ln -s $TEMP_FOLDER $REPO_FOLDER/perks/common/temp
ln -s $TEMP_FOLDER $REPO_FOLDER/autorest/common/temp
ln -s $TEMP_FOLDER $REPO_FOLDER/autorest.powershell/common/temp
ln -s $TEMP_FOLDER $REPO_FOLDER/autorest.remodeler/common/temp

# first perks
cd $REPO_FOLDER/perks
rush publish --publish --pack --include-all 

# publish those to the local package service
for file in $REPO_FOLDER/common/temp/artifacts/packages/*.tgz 
do
  npm publish $file --tag latest --access public --registry http://localhost:4873 || echo no-worries 
done

cd $REPO_FOLDER/autorest
rush publish --publish --pack --include-all 

cd $REPO_FOLDER/autorest.powershell
rush publish --publish --pack --include-all 

cd $REPO_FOLDER/autorest.remodeler
rush publish --publish --pack --include-all 


# and now publish the rest to the local package service
for file in $REPO_FOLDER/common/temp/artifacts/packages/*.tgz 
do
  npm publish $file --tag latest --access public --registry http://localhost:4873 || echo no-worries 
done

# remove our temp folder symlinks
unlink $REPO_FOLDER/perks/common/temp
unlink $REPO_FOLDER/autorest/common/temp
unlink $REPO_FOLDER/autorest.powershell/common/temp
unlink $REPO_FOLDER/autorest.remodeler/common/temp


popd