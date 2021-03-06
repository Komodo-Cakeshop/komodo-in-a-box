
function bsk {

input_box "Blockchain Starter Kit - Step 1" "Name of chain?" "HELLOWORLD" CHAIN

while true
do

### display main menu ###
dialog --clear  --help-button --backtitle "Cakeshop Console" \
--title "[ Blockchain Starter Kit - $CHAIN ]" \
--menu "You can use the UP/DOWN arrow keys, the first \n\
letter of the choice as a hot key. \n\
\n\
Choose the Seed or Mining Menu" 25 120 14 \
SEED-MENU "BSK - $CHAIN seed control" \
MINING-MENU "BSK - $CHAIN mining control" \
TOKENS "Use the tokenization system on this blockchain" \
WALLET "Use this node $CHAIN wallet" \
Back "Back a menu" 2>"${INPUT}"

menuitem=$(<"${INPUT}")


# make decsion
case $menuitem in
	SEED-MENU) bsk_seed_menu;;
	MINING-MENU) bsk_mining_menu;;
  TOKENS) tokens;;
  WALLET) wallet;;
	Back) echo "Bye"; break;;
esac
done
}

function wallet {
  KIABMETHOD="listunspent"
  if ps aux | grep -i $CHAIN ; then
    source ~/.komodo/$CHAIN/$CHAIN.conf
    source $HOME/.devwallet
    submenu_wallet
  else
    echo "Nothing to query - start $CHAIN..."
    sleep 1
  fi
}

function tokens {
  KIABMETHOD="listunspent"
  if ps aux | grep -i $CHAIN ; then
    source ~/.komodo/$CHAIN/$CHAIN.conf
    source ~/.devwallet
    submenu_tokens
  else
    echo "Nothing to query - start $CHAIN..."
    sleep 1
  fi
}


function bsk_seed_menu {
while true
do

### display main menu ###
dialog --clear  --help-button --backtitle "Cakeshop Console" \
--title "[ Blockchain Starter Kit - $CHAIN Seed Menu ]" \
--menu "You can use the UP/DOWN arrow keys, the first \n\
letter of the choice as a hot key, or the \n\
number keys 1-9 to choose an option.\n\
Choose the TASK" 25 120 14 \
SEED-GETINFO "BSK $CHAIN seed getinfo" \
NEW-NODE-SEED "Create a BSK $CHAIN seed node" \
SHUTDOWN-NODE-SEED "Shutdown $CHAIN seed node" \
COINGW "Experimental: Coin Gateway" \
Back "Back a menu" 2>"${INPUT}"

menuitem=$(<"${INPUT}")


# make decsion
case $menuitem in
	NEW-NODE-SEED) bsk_seed_spinup;;
	SEED-GETINFO) bsk_seed_getinfo;;
  COINGW) coingw;;
	SHUTDOWN-NODE-SEED) bsk_seed_shutdown;;
	Back) echo "Bye"; break;;
esac
done
}

function bsk_mining_menu {
while true
do

### display main menu ###
dialog --clear  --help-button --backtitle "Cakeshop Console" \
--title "[ Blockchain Starter Kit - $CHAIN Mining Menu ]" \
--menu "You can use the UP/DOWN arrow keys, the first \n\
letter of the choice as a hot key, or the \n\
number keys 1-9 to choose an option.\n\
Choose the TASK" 25 120 14 \
MINER-GETINFO "BSK $CHAIN mining getinfo" \
MINER-GETMININGINFO "BSK $CHAIN mining getmininginfo" \
MINING-START "BSK $CHAIN start mining" \
MINING-STOP "BSK $CHAIN mining stop" \
IMPORT-DEV-WALLET "BSK $CHAIN import the dev wallet of this node" \
NEW-NODE-MINER "Create a BSK $CHAIN mining node" \
COINGW "Experimental: Coin Gateway" \
SHUTDOWN-NODE-MINER "Shutdown $CHAIN mining node" \
Back "Back a menu" 2>"${INPUT}"

menuitem=$(<"${INPUT}")


# make decsion
case $menuitem in
	NEW-NODE-MINER) bsk_mining_spinup;;
	MINER-GETINFO) bsk_mining_getinfo;;
	MINER-GETMININGINFO) bsk_mining_getmininginfo;;
	MINING-START) bsk_mining_start;;
	MINING-STOP) bsk_mining_stop;;
  COINGW) coingw;;
	IMPORT-DEV-WALLET) bsk_mining_importdevwallet;;
	SHUTDOWN-NODE-MINER) bsk_mining_shutdown;;
	Back) echo "Bye"; break;;
esac
done
}


function bsk_seed_spinup {
    if ps aux | grep -i $CHAIN | grep -iv "coinData\|grep" ; then
	    echo "seed node for name $CHAIN running, use different name"
	    sleep 2
    else
      input_box "$CHAIN" "How many $CHAIN coins?" "1000" SUPPLY
      source ~/.devwallet
      echo $SUPPLY
      sleep 1
      echo $CHAIN
      sleep 1
      echo "BSK_$CHAIN=-ac_supply=$SUPPLY" >> ~/.komodoinabox.conf
      hide_output komodod -ac_name=$CHAIN -ac_supply=$SUPPLY -pubkey=$DEVPUBKEY -ac_cc=2 &>/dev/null &
      sleep 1
      sleep 1
      source ~/.komodo/$CHAIN/$CHAIN.conf
      echo "Finishing seed node setup"
      sleep 5
      curl -s --user $rpcuser:$rpcpassword --data-binary "{\"jsonrpc\": \"1.0\", \"id\": \"curltest\", \"method\": \"importprivkey\", \"params\": [\"$DEVWIF\"]}" -H 'content-type: text/plain;' http://127.0.0.1:$rpcport/ | jq -r '.result'
      sleep 1
    fi
}

function bsk_seed_getinfo {
  CHAIN=$CHAIN
  METHOD="getinfo"
  if ps aux | grep -i $CHAIN | grep -v grep ; then
    source ~/.komodo/$CHAIN/$CHAIN.conf
    curl -s --user $rpcuser:$rpcpassword --data-binary "{\"jsonrpc\": \"1.0\", \"id\": \"curltest\", \"method\": \"$METHOD\", \"params\": []}" -H 'content-type: text/plain;' http://127.0.0.1:$rpcport/ | jq -r '.result' > ~/.$METHOD
    MSGBOXINFO=`cat ~/.$METHOD`
    message_box "$METHOD" "$MSGBOXINFO"
  else
    echo "Nothing to query - start $CHAIN..."
    sleep 1
  fi
}


function bsk_seed_shutdown {
  source ~/.komodo/$CHAIN/$CHAIN.conf
  RESULT=`curl -s --user $rpcuser:$rpcpassword --data-binary "{\"jsonrpc\": \"1.0\", \"id\": \"curltest\", \"method\": \"stop\", \"params\": []}" -H 'content-type: text/plain;' http://127.0.0.1:$rpcport/ | jq -r '.result'`
  echo $RESULT
  sleep 1
}

function bsk_mining_getinfo {
  CHAIN=$CHAIN
  METHOD="getinfo"
  if ps aux | grep -i $CHAIN ; then
    source ~/.komodo/$CHAIN/$CHAIN.conf
    curl -s --user $rpcuser:$rpcpassword --data-binary "{\"jsonrpc\": \"1.0\", \"id\": \"curltest\", \"method\": \"$METHOD\", \"params\": []}" -H 'content-type: text/plain;' http://127.0.0.1:$rpcport/ | jq -r '.result' > ~/.$METHOD
    MSGBOXINFO=`cat ~/.$METHOD`
    message_box "$METHOD" "$MSGBOXINFO"
  else
    echo "Nothing to query - start $CHAIN..."
    sleep 1
  fi
}

function bsk_mining_getmininginfo {
  CHAIN=$CHAIN
  METHOD="getmininginfo"
  if ps aux | grep -i $CHAIN ; then
    source ~/.komodo/$CHAIN/$CHAIN.conf
    curl -s --user $rpcuser:$rpcpassword --data-binary "{\"jsonrpc\": \"1.0\", \"id\": \"curltest\", \"method\": \"$METHOD\", \"params\": []}" -H 'content-type: text/plain;' http://127.0.0.1:$rpcport/ | jq -r '.result' > ~/.$METHOD
    MSGBOXINFO=`cat ~/.$METHOD`
    message_box "$METHOD" "$MSGBOXINFO"
  else
    echo "Nothing to query - start $CHAIN..."
    sleep 1
  fi
}


function bsk_mining_spinup {
  if ps aux | grep $CHAIN | grep -v grep; then
    echo "Already running a mining node"
    sleep 2
  else
    if [ -d ~/.komodo/$CHAIN ]; then
	    echo "$CHAIN already been a mining node, no need to mkdir"
	    sleep 1
    else
      echo "This section may only be needed for BSK-1-node setups, and not BSK in general"
      # input_box "$CHAIN" "How many $CHAIN coins?\n\nNote: Must be same as seed node" "1000" SUPPLY
      # NEWRPCPORT=$(shuf -i 25000-25500 -n 1)
      # TRYAGAIN=1
      # while [ $TRYAGAIN -eq 1 ]
      # do
	    #   NEWPORT=$(( NEWRPCPORT - 1 ))
	    #   echo "Seeing if ports are available for RPC/P2P $NEWPORT / $NEWRPCPORT"
	    #   sleep 1
	    #   if netstat -ptan | grep "$NEWRPCPORT\|$NEWPORT" ; then
		  #     NEWRPCPORT=$(shuf -i 25000-25500 -n 1)
		  #     echo "Try again...with $NEWRPCPORT"
		  #     sleep 1
	    #   else
		  #     TRYAGAIN=0
	    #   fi

      # done
      # mkdir -p ~/.komodo/$CHAIN
      # cp ~/.komodo/$CHAIN/$CHAIN.conf ~/coinData/$CHAIN
      # newrpcuser=$(dd bs=24 count=1 if=/dev/urandom | base64 | tr +/ _.)
      # newrpcpassword=$(dd bs=24 count=1 if=/dev/urandom | base64 | tr +/ _.)
      # sed -i "s/^\(rpcuser=\).*$/rpcuser=$newrpcuser/" ~/coinData/$CHAIN/$CHAIN.conf
      # sed -i "s/^\(rpcpassword=\).*$/rpcpassword=$newrpcpassword/" ~/coinData/$CHAIN/$CHAIN.conf
      # echo "port=$NEWPORT" >> ~/coinData/$CHAIN/$CHAIN.conf
      # sed -i "s/^\(rpcport=\).*$/rpcport=$NEWRPCPORT/" ~/coinData/$CHAIN/$CHAIN.conf
      # echo "Created datadir for single host BSK"
      # sleep 2
    fi
    source ~/.devwallet
    input_box "$CHAIN" "How many $CHAIN coins?\n\nNote: Must be same as seed node" "1000" SUPPLY
    input_box "$CHAIN" "Connect to the seed node at what (IP) address?\n\nNote: Must be same as seed node" "1.2.3.4" SEEDNODE
    hide_output komodod -ac_name=$CHAIN -ac_supply=$SUPPLY -pubkey=$DEVPUBKEY -addnode=$SEEDNODE -ac_cc=2 & #>/dev/null &
    echo "Finished mining node setup"
    echo "Ready to enable mining..."
    sleep 5
    cat ~/.komodo/$CHAIN/$CHAIN.conf
    sleep 3
  fi
}

function bsk_mining_importdevwallet {
  if ps aux | grep -i $CHAIN ; then
    source ~/.komodo/$CHAIN/$CHAIN.conf
    source ~/.devwallet
    echo "Importing $DEVADDRESS"
    sleep 2
    curl -s --user $rpcuser:$rpcpassword --data-binary "{\"jsonrpc\": \"1.0\", \"id\": \"curltest\", \"method\": \"importprivkey\", \"params\": [\"$DEVWIF\"]}" -H 'content-type: text/plain;' http://127.0.0.1:$rpcport/ | jq -r '.result'
    sleep 1
  else
    echo "Mining node not running"
    sleep 2
  fi
}

function bsk_mining_start {
  if ps aux | grep -i $CHAIN ; then
	  echo "Staring mining on $CHAIN"
	  sleep 3
    source ~/.komodo/$CHAIN/$CHAIN.conf
    RESULT=`curl -s --user $rpcuser:$rpcpassword --data-binary "{\"jsonrpc\": \"1.0\", \"id\": \"curltest\", \"method\": \"setgenerate\", \"params\": [true,1]}" -H 'content-type: text/plain;' http://127.0.0.1:$rpcport/ | jq -r '.result'`
    echo $RESULT
    sleep 1
  else
    echo "Mining node not running"
    sleep 2
  fi
}

function bsk_mining_stop {
  if ps aux | grep -i $CHAIN ; then
    source ~/.komodo/$CHAIN/$CHAIN.conf
    RESULT=`curl -s --user $rpcuser:$rpcpassword --data-binary "{\"jsonrpc\": \"1.0\", \"id\": \"curltest\", \"method\": \"setgenerate\", \"params\": [false]}" -H 'content-type: text/plain;' http://127.0.0.1:$rpcport/ | jq -r '.result'`
    #echo $RESULT
    sleep 1
  else
    echo "Mining node not running"
    sleep 2
  fi
}

function bsk_mining_shutdown {
  if ps aux | grep -i $CHAIN ; then
    source ~/.komodo/$CHAIN/$CHAIN.conf
    RESULT=`curl -s --user $rpcuser:$rpcpassword --data-binary "{\"jsonrpc\": \"1.0\", \"id\": \"curltest\", \"method\": \"stop\", \"params\": []}" -H 'content-type: text/plain;' http://127.0.0.1:$rpcport/ | jq -r '.result'`
    echo $RESULT
    sleep 1
  else
    echo "Mining node not running"
    sleep 2
  fi
}