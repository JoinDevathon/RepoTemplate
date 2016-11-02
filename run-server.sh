#!/bin/bash

if [ ! -d "server" ] || [ ! -d "build" ]; then
    echo "Spigot is not downloaded, downloading and building now.."
    bash download-spigot.sh
    mkdir -p server/plugins
fi

if [ ! -f "server/spigot.jar" ]; then
    cp build/spigot-1.10.2.jar server/spigot.jar
fi

if [ ! -f "server/eula.txt" ]; then
    read -p "Do you accept the Mojang EULA? If not, then exit the program now. Otherwise, press Enter."
    echo "eula=true" > server/eula.txt
fi

_term() {
    echo "stop" > /tmp/srv-input
    exit
}
trap _term EXIT

while true; do
    mvn clean install
    cp target/DevathonProject-1.0-SNAPSHOT.jar server/plugins/DevathonProject-1.0-SNAPSHOT.jar
    cd server

    # set up out process
    rm -f /tmp/srv-input

    mkfifo /tmp/srv-input
    cat > /tmp/srv-input &
    tail -f /tmp/srv-input | java -jar spigot.jar &

    running=true
    while $running; do
        read input
        if [ "$input" == "stop" ]; then
            running=false
            echo "stop" > /tmp/srv-input
        elif [ "$input" == "exit" ]; then
            running=false
            echo "stop" > /tmp/srv-input
            sleep 2
            exit
        else
            echo "$input" > /tmp/srv-input
        fi

        sleep 1
    done
    cd ..

    echo "Rebuilding project.."
    sleep 1
done
