// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/utils/Base64.sol";

contract NFTZen is ERC721URIStorage  {
    using Strings for uint256;
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    mapping(uint256 => uint256) public tokenIdToLastFed;
    mapping (address => uint256) private addressToTokenId;

    function getLastFed() public view returns (string memory) {
        uint256 currentTokenId = addressToTokenId[msg.sender];
        uint256 lastFed = tokenIdToLastFed[currentTokenId];
        return lastFed.toString();
    }

    function mint() public {
        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _safeMint(msg.sender, newTokenId);
        addressToTokenId[msg.sender] = newTokenId;
        tokenIdToLastFed[newTokenId] = block.timestamp;
    }

    function feed() public returns (string memory){
        uint256 newLastFed =  block.timestamp;
        uint256 currentTokenId = addressToTokenId[msg.sender];

        require(_exists(currentTokenId), "Please use an existing token");
        require(ownerOf(currentTokenId) == msg.sender, "You must own this token to feed it");
        
        tokenIdToLastFed[currentTokenId] = newLastFed;
        return newLastFed.toString();
    }

    constructor() ERC721 ("NFTZen", "CBTLS"){
    }
}