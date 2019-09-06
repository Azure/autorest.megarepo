for file in common/temp/artifacts/packages/*.tgz 
do
  npm publish $file --tag latest --access public --registry http://localhost:4873 || echo no-worries 
done