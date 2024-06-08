echo "Building disembark.phar"
php -d phar.readonly=0 build-phar.php

echo "Installing disembark.phar to /usr/local/bin/disembark"
chmod +x disembark.phar
sudo mv disembark.phar /usr/local/bin/disembark