if ! which teamviewer > /dev/null; then
    echo "Must have teamviewer installed"
    exit 1
fi

echo "Starting service"
sudo systemctl restart teamviewerd || exit 1
sleep 1

echo "Starting teamviewer"
teamviewer || exit 1
sleep 1

echo "Stopping service"
sudo systemctl stop teamviewerd
sleep 1
