#if( ${containerObject} )
#set( $appName = "Container-${containerObject.getName()}" )
#else
#set( $appName = $aib.getApplicationNameFormatted() )
#end
#!/bin/bash

mkdir appRoot
cd appRoot && ng new ${appName} --defaults
cp -r -n /appRoot/${appName}/ /gitRoot/
cd /gitRoot/${appName} && npm install --prod && npm run setup
cd /gitRoot/${appName} && ng build
cp -r -n /gitRoot/ /code/