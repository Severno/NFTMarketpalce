// SPDX-License-Identifier: MIT
pragma solidity ^0.8.11;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract NFTBoredCryptons is Ownable, ERC721URIStorage {
    using Counters for Counters.Counter;
    Counters.Counter private id;

    constructor(string memory _name, string memory _symbol)
        ERC721(_name, _symbol)
    {}

    function safeMint(address _to, string memory _tokenURI)
        public
        onlyOwner
        returns (uint256)
    {
        id.increment();

        uint256 NFTId = id.current();
        _safeMint(_to, NFTId);
        _setTokenURI(NFTId, _tokenURI);

        return NFTId;
    }
}
