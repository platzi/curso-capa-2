// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract HelloWorld {
    string public hello = "Hola mundo!";

    function setHello(string memory hello_) public
    {
        hello = hello_;
    }
}