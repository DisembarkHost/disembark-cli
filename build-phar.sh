if [ -f disembark.phar ]; then 
    rm disembark.phar
fi
echo "Building disembark.phar"
php -d phar.readonly=0 build-phar.php
chmod +x disembark.phar