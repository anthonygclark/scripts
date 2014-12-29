if ! which teamviewer > /dev/null; then
    echo "Must have teamviewer installed"
    exit 1
fi

echo "Starting service"
sudo systemctl restart teamviewerd

echo "Starting teamviewer"
teamviewer

sudo systemctl stop teamviewerd
