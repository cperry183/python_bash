#!/usr/bin/env bash 
set -x 

/usr/local/rvm/bin/rvm ruby-2.4 do gem install domain_name -v 0.5.20190701
/usr/local/rvm/bin/rvm ruby-2.4 do gem install --no-document rest-client
/usr/local/rvm/bin/rvm ruby-2.4 do gem install aws-sigv4 -v 1.6.1
/usr/local/rvm/bin/rvm ruby-2.4 do gem install aws-eventstream -v 1.2.0
/usr/local/rvm/bin/rvm ruby-2.4 do gem install --no-document vault
/usr/local/rvm/bin/rvm ruby-2.4 do gem install thor -v 1.2.2
/usr/local/rvm/bin/rvm ruby-2.4 do gem install mini_mime -v 1.1.2
/usr/local/rvm/bin/rvm ruby-2.4 do gem install ffi -v 1.15.5
/usr/local/rvm/bin/rvm ruby-2.4 do gem install colorize -v 0.8.1
/usr/local/rvm/bin/rvm ruby-2.4 do gem install public_suffix -v 4.0.7
/usr/local/rvm/bin/rvm ruby-2.4 do gem install --no-document harbor_swagger_client
