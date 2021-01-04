#if( $containerObject )
#set( $repoName = "${aib.getApplicationNameFormatted()}.${containerObject.getName()}" )
#else
#set( $repoName = ${aib.getParam("git.repository")} )
#end
#set( $gitTag = ${aib.getParam("git.tag")} )
#!/bin/bash
cd $1

git config --global user.email "dev@realmethods.com"
git config --global user.name "Scrum Master"
 
echo init the repository
git init .

echo add all files from root dir below, with ignore dirs and files in the .gitignore
git add .

echo 'commit all the files'
git commit -m "initial commit"

echo 'add a remote pseudo for the ${repoName} repository'
git remote add ${repoName} https://${aib.getParam("git.username")}:${aib.getParam("git.password")}@${aib.getParam("git.host")}/${aib.getParam("git.username")}/${aib.getParam("git.repository")}

echo 'push the commits to the repository master'
git push ${repoName} master

echo 'delete tag ${gitTag}'
git tag -d ${gitTag}
git push --delete ${repoName} ${gitTag}

echo 'add tag ${gitTag}'
git tag ${gitTag}

echo 'push tag ${gitTag}'
git push ${repoName} ${gitTag}

