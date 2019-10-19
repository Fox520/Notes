cd ~/Documents/Notes/noter-service/src/noter
docker-compose down
cd ~/Documents/Notes/noter-service/src/noter
echo "starting build #1"
ballerina build main.bal
python3 prepare_ports.py
echo "starting build #2"
ballerina build main.bal
python3 prepare_ports.py
echo "starting build #3"
ballerina build main.bal
python3 prepare_ports.py
echo "starting build #4"
ballerina build main.bal
python3 prepare_ports.py
echo "starting build #5"
ballerina build main.bal
docker-compose up -d
echo "done"