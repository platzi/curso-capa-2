1. Lanza el Smart contract en [Remix](https://remix.ethereum.org/)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract HelloWorld {
    string public hello = "Hola mundo!";

    function setHello(string memory hello_) public
    {
        hello = hello_;
    }
}
```

2. Crea el archivo HTML

`index.html`
```html
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8">
</head>
<body>
  <input id="connect_button" type="button" value="Connect" onclick="connectWallet()" style="display: none"></input>
  <p id="web3_message"></p>
  <p id="contract_state"></p>
  <h1>Hola Mundo! DApp</h1>
  <p id="hello"></p>
  <input type="input"  value="" id="hello_"></input>
  <input type="button" value="Set Hello" onclick="_setHello()"></input>
  <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/web3/1.3.5/web3.min.js"></script>
  <script type="text/javascript" src="blockchain_stuff.js"></script>
</body>
</html>

<script>
  function _setHello()
  {
    hello_ = document.getElementById("hello_").value
    setHello(hello_)
  }
</script>
```

3. Crea el archivo de JS

`blockchain_stuff.js`
```js
const NETWORK_ID = 421611
const HELLO_WORLD_CONTRACT_ADDRESS = "0x278FD7D85f8A22bDa8a0d1E34602108A2DFE5275"
const HELLO_WORLD_ABI_PATH = "./HelloWorld.json"

var helloWorldContract
var accounts
var web3

function metamaskReloadCallback() {
  window.ethereum.on('accountsChanged', (accounts) => {
    document.getElementById("web3_message").textContent="Account changed, refreshing...";
    window.location.reload()
  })
  window.ethereum.on('networkChanged', (accounts) => {
    document.getElementById("web3_message").textContent="Network changed, refreshing...";
    window.location.reload()
  })
}

const getWeb3 = async () => {
  return new Promise((resolve, reject) => {
    if(document.readyState=="complete")
    {
      if (window.ethereum) {
        const web3 = new Web3(window.ethereum)
        window.location.reload()
        resolve(web3)
      } else {
        reject("must install MetaMask")
        document.getElementById("web3_message").textContent="Error: Please connect to metamask";
      }
    }else
    {
      window.addEventListener("load", async () => {
        if (window.ethereum) {
          const web3 = new Web3(window.ethereum)
          resolve(web3)
        } else {
          reject("must install MetaMask")
          document.getElementById("web3_message").textContent="Error: Please install Metamask";
        }
      });
    }
  });
};

const getContract = async (web3, address, abi_path) => {
  const response = await fetch(abi_path);
  const data = await response.json();
  
  const netId = await web3.eth.net.getId();
  contract = new web3.eth.Contract(
    data,
    address
    );
  return contract
}

async function loadDapp() {
  metamaskReloadCallback()
  document.getElementById("web3_message").textContent="Please connect to Metamask"
  var awaitWeb3 = async function () {
    web3 = await getWeb3()
    web3.eth.net.getId((err, netId) => {
      if (netId == NETWORK_ID) {
        var awaitContract = async function () {
          helloWorldContract = await getContract(web3, HELLO_WORLD_CONTRACT_ADDRESS, HELLO_WORLD_ABI_PATH)
          document.getElementById("web3_message").textContent="You are connected to Metamask"
          onContractInitCallback()
          web3.eth.getAccounts(function(err, _accounts){
            accounts = _accounts
            if (err != null)
            {
              console.error("An error occurred: "+err)
            } else if (accounts.length > 0)
            {
              onWalletConnectedCallback()
            } else
            {
              document.getElementById("connect_button").style.display = "block"
            }
          });
        };
        awaitContract();
      } else {
        document.getElementById("web3_message").textContent="Please connect to Arbitrum Testnet";
      }
    });
  };
  awaitWeb3();
}

async function connectWallet() {
  await window.ethereum.request({ method: "eth_requestAccounts" })
  accounts = await web3.eth.getAccounts()
  onWalletConnectedCallback()
}

loadDapp()

const onContractInitCallback = async () => {
  var hello = await helloWorldContract.methods.hello().call()
  document.getElementById("hello").textContent = hello;
}

const onWalletConnectedCallback = async () => {
}

//// Functions ////

const setHello = async (hello_) => {
  const result = await helloWorldContract.methods.setHello(hello_)
  .send({ from: accounts[0], gas: 0, value: 0 })
  .on('transactionHash', function(hash){
    document.getElementById("web3_message").textContent="Executing...";
  })
  .on('receipt', function(receipt){
    document.getElementById("web3_message").textContent="Success.";    })
  .catch((revertReason) => {
    console.log("ERROR! Transaction reverted: " + revertReason.receipt.transactionHash)
  });
}
```

4. Coloca el archivo JSON ABI

`HelloWorld.json`
```json
[
  {
    "inputs": [
      {
        "internalType": "string",
        "name": "hello_",
        "type": "string"
      }
    ],
    "name": "setHello",
    "outputs": [],
    "stateMutability": "nonpayable",
    "type": "function"
  },
  {
    "inputs": [],
    "name": "hello",
    "outputs": [
      {
        "internalType": "string",
        "name": "",
        "type": "string"
      }
    ],
    "stateMutability": "view",
    "type": "function"
  }
]
```

5. Interactua con el sitio web

```bash
npm install -g lite-server
lite-server
```

Ahora te puedes dirigir a `localhost:3000` en tu browser para interactuar con la DApp.