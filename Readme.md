# En Optimism

1. Agrega Optimism Goerli a tu Wallet de Metamask, puedes hacerlo a través de [Optimism Scan](https://goerli-optimism.etherscan.io/)

2. Obten fondos a través del [Bridge](https://app.optimism.io/bridge/deposit)

3. Lanza un contrato en L2

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

4. Lanza un contrato en Goerli L1

```solidity
// SPDX-License-Identifier: MIT
pragma solidity  0.8.17;

interface CrossDomainMessenger {
    function sendMessage(address _target, bytes memory _message, uint32 _minGasLimit) payable external;
}

contract HelloWorldOperatorL1 {
    CrossDomainMessenger ovmL1CrossDomainMessenger = CrossDomainMessenger(0x5086d1eEF304eb5284A0f6720f79403b4e9bE294);

    function executeFuncionInL2(address l2ContractAddress, string memory hello_, uint32 gasLimit) public
    {
        ovmL1CrossDomainMessenger.sendMessage(
            l2ContractAddress,
            abi.encodeWithSignature(
                "setHello(string)",
                hello_
            ),
            gasLimit
        );
    }
}
```

5. Interactua con el contrato en L2 desde L1

Ejecuta la funcion `executeFuncionInL2` enviándole los siguientes parámetros:

* l2ContractAddress: el address del contrato en L2
* hello_: el valor que recibirá de parámetro `setHello` en L2
* gasLimit: es negilible para funciones pequeñas, puedes enviar `10000000` de parámetro para ejecuciones mas grandes

# En Arbitrum (Deprecado)

1. Contrato en arbitrum testnet

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

2. Contrato en Rinkeby Testnet

```solidity
// SPDX-License-Identifier: MIT
pragma solidity  0.8.17;

interface IInbox {
    function createRetryableTicket(
        address destAddr,
        uint256 l2CallValue,
        uint256 maxSubmissionCost,
        address excessFeeRefundAddress,
        address callValueRefundAddress,
        uint256 maxGas,
        uint256 gasPriceBid,
        bytes calldata data
    ) external payable returns (uint256);
}

interface IHelloWorld {
    function setHello(string memory hello_) external;
}

contract L2Operator {
    IInbox inbox = IInbox(0x6bebc4925716945d46f0ec336d5c2564f419682c);

    function setHelloInL2(
        address l2ContractAddress,
        string memory _hello,
        uint256 maxSubmissionCost,
        uint256 maxGas,
        uint256 gasPriceBid
    ) public payable returns (uint256) {
        bytes memory data =
            abi.encodeWithSelector(IHelloWorld.setHello.selector, _hello);
        uint256 ticketID = inbox.createRetryableTicket{value: msg.value}(
            l2ContractAddress,
            0,
            maxSubmissionCost,
            msg.sender,
            msg.sender,
            maxGas,
            gasPriceBid,
            data
        );
        return ticketID;
    }
}
```

3. Parametros

* l2ContractAddress: ADDRESS DE CONTRATO EN L2
* _hello: `¡Hemos ejecutado esto desde L1!`
* maxSubmissionCost: `80000000000`
* maxGas: `90000000`
* gasPriceBid: `90000000`
* Value: `0.01` gas ether