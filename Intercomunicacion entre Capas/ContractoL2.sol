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