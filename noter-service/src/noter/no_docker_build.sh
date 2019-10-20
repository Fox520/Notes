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
echo "done"