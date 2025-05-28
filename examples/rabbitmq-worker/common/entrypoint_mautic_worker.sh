#!/bin/bash

# install twig plugin
if [ -f /var/www/html/docroot/plugins/MauticTwigTemplatesBundle/MauticTwigTemplatesBundle.php ] && [ -f /var/www/html/config/local.php ] && grep -q "site_url" /var/www/html/config/local.php; then
	echo "Mautic is installed before current deployment so we can run commands to clear cache, reload plugins and re-generate assets"
	rm -rf /var/www/html/var/tmp && mkdir /var/www/html/var/tmp && chmod 777 /var/www/html/var/tmp # temp permission fix
	su -s /bin/bash www-data -c 'php /var/www/html/bin/console cache:clear  && php /var/www/html/bin/console mautic:plugins:reload && php /var/www/html/bin/console mautic:assets:generate'
else
	echo "Mautic is not installed before current deployment or Twig plugin does not exist so we will not run commands to clear cache, reload plugins and re-generate assets"
fi

# wait until Mautic is installed
until php -r 'file_exists("/var/www/html/config/local.php") ? include("/var/www/html/config/local.php") : exit(1); exit(isset($parameters["site_url"]) ? 0 : 1);'; do
	echo "Mautic not installed, waiting to start workers"
	sleep 5
done

supervisord -c /etc/supervisor/conf.d/supervisord.conf
