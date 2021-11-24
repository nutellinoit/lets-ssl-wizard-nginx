#!/usr/bin/env bash
cat << "EOF"
            ,    _
           /|   | |
         _/_\_  >_<
        .-\-/.   |
       /  | | \_ |
       \ \| |\__(/
       /(`---')  |
      / /     \  |
   _.'  \'-'  /  |
   `----'`=-='   '
EOF

while test $# -gt 0; do
           case "$1" in
                -domain)
                    shift
                    DOMAIN=$1
                    shift
                    ;;
                -reverseurl)
                    shift
                    REVERSEURL=$1
                    shift
                    ;;
                -www)
                    shift
                    WWW=$1
                    shift
                    ;;
                -staging)
                    shift
                    STAGING=$1
                    shift
                    ;;
                -aws)
                    shift
                    AWS=$1
                    shift
                    ;;
                *)
                   echo "$1 is not a recognized flag!"
                   return 1;
                   ;;
          esac
  done

echo "write the DOMAIN that you want to configure  (es merlinthewizard.com) without www!!!!!!!"
if [ -z "$DOMAIN" ]; then
    read -p "DOMAIN: " DOMAIN
else
    echo "DOMAIN: $DOMAIN"
fi

echo "Which reverse configure? eg http://192.160.1.1:8080"
if [ -z "$REVERSEURL" ]; then
    read -p "REVERSEURL: " REVERSEURL
else
    echo "REVERSEURL: $REVERSEURL"
fi

echo "Do you want also redirect to www? (answer Y o N)"
if [ -z "$WWW" ]; then
    read -p "type Y or N: " WWW
else
    echo "WWW: $WWW"
fi

echo "Issue staging ssl? (answer Y o N)"
if [ -z "$STAGING" ]; then
    read -p "type Y for staging or N for production: " STAGING
else
    echo "STAGING: $STAGING"
fi

echo "Use http challenge or aws? (answer H o A)"
if [ -z "$AWS" ]; then
    read -p "type H for http challenge or A for aws DNS challenge: " AWS
else
    echo "AWS: $AWS"
fi


DNS_STRING=''

if [ "$AWS" = "A" ]; then
  DNS_STRING='--dns dns_aws'
fi

echo "Thanks, wizard starting in 2 secs!"
sleep 2

echo "Copy start template..."

if [ "$WWW" = "Y" ]; then
 cp template.www.vhosts.start.conf /etc/nginx/conf.d/${DOMAIN}.conf
else
 cp template.vhosts.start.conf /etc/nginx/conf.d/${DOMAIN}.conf
fi

echo "Sedding..."

sed -i 's!HOSTNAME!'${DOMAIN}'!g' /etc/nginx/conf.d/${DOMAIN}.conf
sed -i 's!REVERSEURL!'${REVERSEURL}'!g' /etc/nginx/conf.d/${DOMAIN}.conf

if [ "$AWS" = "H" ]; then
    sed -i 's!#####!!g' /etc/nginx/conf.d/${DOMAIN}.conf
fi

echo "Folder creation..."

mkdir /var/www/html/${DOMAIN}/
chmod -R 777 /var/www/html/${DOMAIN}/

echo "Nginx reload"

service nginx reload



if [ "$STAGING" = "Y" ]; then
  if [ "$WWW" = "Y" ]; then
    ~/.acme.sh/acme.sh --issue --staging ${DNS_STRING} -d ${DOMAIN} ${DNS_STRING} -d www.${DOMAIN} -w /var/www/html/${DOMAIN}/
  else
    ~/.acme.sh/acme.sh --issue --staging ${DNS_STRING} -d ${DOMAIN} -w /var/www/html/${DOMAIN}/
  fi
else
  if [ "$WWW" = "Y" ]; then
    ~/.acme.sh/acme.sh --issue ${DNS_STRING} -d ${DOMAIN} ${DNS_STRING} -d www.${DOMAIN} -w /var/www/html/${DOMAIN}/
  else
    ~/.acme.sh/acme.sh --issue ${DNS_STRING} -d ${DOMAIN} -w /var/www/html/${DOMAIN}/
  fi
fi


rm /etc/nginx/conf.d/${DOMAIN}.conf

if [ "$WWW" = "Y" ]; then
 cp template.www.vhosts.end.conf /etc/nginx/conf.d/${DOMAIN}.conf
else
 cp template.vhosts.end.conf /etc/nginx/conf.d/${DOMAIN}.conf
fi

sed -i 's!HOSTNAME!'${DOMAIN}'!g' /etc/nginx/conf.d/${DOMAIN}.conf
sed -i 's!REVERSEURL!'${REVERSEURL}'!g' /etc/nginx/conf.d/${DOMAIN}.conf

if [ "$AWS" = "H" ]; then
    sed -i 's!#####!!g' /etc/nginx/conf.d/${DOMAIN}.conf
fi

echo "Nginx reload"

service nginx reload

echo "Complete!"
