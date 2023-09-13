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

# Clear caches
$FORGE_PHP artisan cache:clear

# Clear and cache routes
$FORGE_PHP artisan route:cache

# Clear and cache config
$FORGE_PHP artisan config:cache

# Clear and cache views
$FORGE_PHP artisan view:cache

# Updating front end resources
touch hash_resources.txt

HASH_RESOURCES="$(cat hash_resources.txt)"

find ./resources ./package-lock.json -type f -print0 | sort -z | xargs -0 sha1sum | sha1sum > hash_resources.txt

HASH_NEW_RESOURCES="$(cat hash_resources.txt)"

if [ "$HASH_RESOURCES" != "$HASH_NEW_RESOURCES" ]; then
  # Install node modules
  npm ci
  
  # Build assets using Laravel Vite
  npm run build
fi

# Turn off maintenance mode
$FORGE_PHP artisan up