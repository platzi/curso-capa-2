1. Instala las dependencias

Debes instalar las siguientes librerías dependiendo de tu sistema operativo.

En Linux
```bash
sudo apt install -y python3.8-venv libgmp3-dev
```

En MaxOs
```bash
brew install python@3.8
brew install gmp
```

En Windows debes instalar Python 3 desde el [sitio web oficial](https://www.python.org/downloads/windows/) y luego estas dependencias a través de `pip`.
```bash
pip3 install ecdsa fastecdsa sympy
```

2. Crea un ambiente virtual en Python

```bash
python3.8 -m venv ~/cairo_venv
source ~/cairo_venv/bin/activate
pip3 install cairo-lang
```

3. Contrato en Cairo

`contract.cairo`
```cairo
// Declare this file as a StarkNet contract.
%lang starknet

from starkware.cairo.common.cairo_builtins import HashBuiltin

// Define a storage variable.
@storage_var
func balance() -> (res: felt) {
}

// Increases the balance by the given amount.
@external
func increase_balance{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
}(amount: felt) {
    let (res) = balance.read();
    balance.write(res + amount);
    return ();
}

// Returns the current balance.
@view
func get_balance{
    syscall_ptr: felt*,
    pedersen_ptr: HashBuiltin*,
    range_check_ptr,
}() -> (res: felt) {
    let (res) = balance.read();
    return (res=res);
}
```

4. Crea una cuenta

```bash
# Conectar a Goerli Testnet
export STARKNET_NETWORK=alpha-goerli
# Usar las wallets de OpenZeppelin
export STARKNET_WALLET=starkware.starknet.wallets.open_zeppelin.OpenZeppelinAccount
# Lanzar el smart contract de la cuenta de usuario
starknet deploy_account
```

5. Lanza un contrato

```bash
# Compilar el contrato
starknet-compile contract.cairo --output contract_compiled.json --abi contract_abi.json
# Lanzar el contrato
starknet deploy --contract contract_compiled.json --no_wallet
```

Luego esperamos a que la transacción tenga el estado `ACCEPTED_ON_L2` con ayuda del siguiente comando:

```bash
starknet tx_status --hash HASH_DE_TRANSACCIÓN
```

6. Interactúa con el contrato

* Braavos Wallet
https://chrome.google.com/webstore/detail/braavos-wallet/jnlgamecbpmbajjfhmmmlhejkemejdma
* Bridge de Starknet desde Goerli
https://goerli.etherscan.io/address/0xc3511006C04EF1d78af4C8E0e74Ec18A6E64Ff9e#writeProxyContract
* Testnet para interacutar con el contrato
https://testnet.starkscan.co/

Nota 1: También puedes interactuar con el contrato desde la línea de comandos

```bash
starknet invoke --address ADDRESS_CONTRATO --abi contract_abi.json --function increase_balance --inputs 1234 --max_fee 25607578957226
starknet tx_status --hash HASH_DE_TRANSACCIÓN
starknet call --address ADDRESS_CONTRATO --abi contract_abi.json --function get_balance
```

Nota 2: El smart contract que lanzamos usando cairo tiene el mismo funcionamiento que el siguiente contrato en solidity

```js
// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract MyContract {
  uint balance;

  function increase_balance(uint amount) public
  {
    balance += amount;
  }

  function get_balance() returns(uint) public view
  {
    return balance;
  }
}
```