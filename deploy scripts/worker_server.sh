# Change to the project directory
cd $FORGE_SITE_PATH

# Turn on maintenance mode
$FORGE_PHP artisan down || true

# reseting git to head
git reset --hard

# Pull the latest changes from the git repository
git pull origin $FORGE_SITE_BRANCH

# Install/update composer dependecies
$FORGE_COMPOSER install --no-interaction --prefer-dist --optimize-autoloader --no-dev

( flock -w 10 9 || exit 1
    echo 'Restarting FPM...'; sudo -S service $FORGE_PHP_FPM reload ) 9>/tmp/fpmlock

# Run database migrations
$FORGE_PHP artisan migrate --force

# Clear caches
$FORGE_PHP artisan cache:clear

# Clear and cache routes
$FORGE_PHP artisan route:cache

# Clear and cache config
$FORGE_PHP artisan config:cache

# Restart queue
$FORGE_PHP artisan queue:restart

# Turn off maintenance mode
$FORGE_PHP artisan up