1. Lanza el contrato llamado `MyImmutableXCollectionDemo` en Goerli testnet via [Remix](https://remix.ethereum.org/)

```solidity
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

library Bytes {
    /**
     * @dev Converts a `uint256` to a `string`.
     * via OraclizeAPI - MIT licence
     * https://github.com/oraclize/ethereum-api/blob/b42146b063c7d6ee1358846c198246239e9360e8/oraclizeAPI_0.4.25.sol
     */
    function fromUint(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        uint256 index = digits - 1;
        temp = value;
        while (temp != 0) {
            buffer[index--] = bytes1(uint8(48 + (temp % 10)));
            temp /= 10;
        }
        return string(buffer);
    }

    bytes constant alphabet = "0123456789abcdef";

    /**
     * Index Of
     *
     * Locates and returns the position of a character within a string starting
     * from a defined offset
     *
     * @param _base When being used for a data type this is the extended object
     *              otherwise this is the string acting as the haystack to be
     *              searched
     * @param _value The needle to search for, at present this is currently
     *               limited to one character
     * @param _offset The starting point to start searching from which can start
     *                from 0, but must not exceed the length of the string
     * @return int The position of the needle starting from 0 and returning -1
     *             in the case of no matches found
     */
    function indexOf(
        bytes memory _base,
        string memory _value,
        uint256 _offset
    ) internal pure returns (int256) {
        bytes memory _valueBytes = bytes(_value);

        assert(_valueBytes.length == 1);

        for (uint256 i = _offset; i < _base.length; i++) {
            if (_base[i] == _valueBytes[0]) {
                return int256(i);
            }
        }

        return -1;
    }

    function substring(
        bytes memory strBytes,
        uint256 startIndex,
        uint256 endIndex
    ) internal pure returns (string memory) {
        bytes memory result = new bytes(endIndex - startIndex);
        for (uint256 i = startIndex; i < endIndex; i++) {
            result[i - startIndex] = strBytes[i];
        }
        return string(result);
    }

    function toUint(bytes memory b) internal pure returns (uint256) {
        uint256 result = 0;
        for (uint256 i = 0; i < b.length; i++) {
            uint256 val = uint256(uint8(b[i]));
            if (val >= 48 && val <= 57) {
                // input is 0-9
                result = result * 10 + (val - 48);
            } else {
                // invalid character, expecting integer input
                revert("invalid input, only numbers allowed");
            }
        }
        return result;
    }
}

library Minting {
    // Split the minting blob into token_id and blueprint portions
    // {token_id}:{blueprint}

    function split(bytes calldata blob)
        internal
        pure
        returns (uint256, bytes memory)
    {
        int256 index = Bytes.indexOf(blob, ":", 0);
        require(index >= 0, "Separator must exist");
        // Trim the { and } from the parameters
        uint256 tokenID = Bytes.toUint(blob[1:uint256(index) - 1]);
        uint256 blueprintLength = blob.length - uint256(index) - 3;
        if (blueprintLength == 0) {
            return (tokenID, bytes(""));
        }
        bytes calldata blueprint = blob[uint256(index) + 2:blob.length - 1];
        return (tokenID, blueprint);
    }
}

interface IMintable {
    function mintFor(
        address to,
        uint256 quantity,
        bytes calldata mintingBlob
    ) external;
}

abstract contract Mintable is Ownable, IMintable {
    address public imx;
    mapping(uint256 => bytes) public blueprints;

    event AssetMinted(address to, uint256 id, bytes blueprint);

    constructor(address _owner, address _imx) {
        imx = _imx;
        require(_owner != address(0), "Owner must not be empty");
        transferOwnership(_owner);
    }

    modifier onlyOwnerOrIMX() {
        require(msg.sender == imx || msg.sender == owner(), "Function can only be called by owner or IMX");
        _;
    }

    function mintFor(
        address user,
        uint256 quantity,
        bytes calldata mintingBlob
    ) external override onlyOwnerOrIMX {
        require(quantity == 1, "Mintable: invalid quantity");
        (uint256 id, bytes memory blueprint) = Minting.split(mintingBlob);
        _mintFor(user, id, blueprint);
        blueprints[id] = blueprint;
        emit AssetMinted(user, id, blueprint);
    }

    function _mintFor(
        address to,
        uint256 id,
        bytes memory blueprint
    ) internal virtual;
}

contract MyImmutableXCollectionDemo is ERC721, Mintable {
    constructor() ERC721("My IMX Collection Demo", "MIMXNFT") Mintable(msg.sender, 0x7917eDb51ecD6CdB3F9854c3cc593F33de10c623) {}

    function _mintFor(
        address user,
        uint256 id,
        bytes memory
    ) internal override {
        _safeMint(user, id);
    }
}
```

Nota dependiendo de tu network puedes escoger el address de IMX en el repositorio de [imx-contracts](https://github.com/immutable/imx-contracts/#immutable-contract-addresses).

2. Crea una cuenta en [Immutable Sandbox](https://market.sandbox.immutable.com/)

3. Clona el [Repositorio de ejemplos](https://github.com/immutable/imx-examples.git)

```bash
git clone https://github.com/immutable/imx-examples.git
cd imx-examples/
npm install
```

4. Crea un proyecto

    1. Crea un archivo `.env` en base a `.env.examples` y edita `OWNER_ACCOUNT_PRIVATE_KEY`, `COLLECTION_CONTRACT_ADDRESS`.
    2. Edita `src/onboarding/2-create-project.ts` para establecer las variables `name`, `company_name` y `contact_email`.
    3. Ejectua `npm run onboarding:create-project`

5. Crear una colección

    1. Edita `COLLECTION_PROJECT_ID` en el archivo `.env`
    2. Edita el `name`, `description`, `icon`, `metadataapiurl`, `collectionimageurl` en el archivo `src/onboarding/3-create-collection.ts`
    3. Ejectua `npm run onboarding:create-collection`

6. Crea el Schema de Metadata

    1. Edita la metadata en `src/onboarding/4-add-metadata-schema.ts`
    2. Ejectua `npm run onboarding:add-metadata-schema`

`ejemplo de schema de metadata`
```ts
{
  name: 'name',
  type: MetadataTypes.Text
},
{
  name: 'image_url',
  type: MetadataTypes.Text
},
{
  name: 'description',
  type: MetadataTypes.Text
},
{
  name: 'attack',
  type: MetadataTypes.Discrete,
  filterable: true
},
```

6. Mintea un NFT

    1. Edita `PRIVATE_KEY1`, `TOKEN_ID`, `TOKEN_ADDRESS` en el archivo `.env`
    2. Edita `wallet` y `number` en el archivo `src/bulk-mint.ts`
```ts
const wallet = "TO ADDRESS PUBLICO AQUI";
const number = 1;
```

3. Ejecuta `npm run bulk-mint`

Ahora tu asset debería estar visible en tu colección en [El Sandbox de Immutable](market.sandbox.immutable.com).