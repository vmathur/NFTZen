// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.8.0/utils/Counters.sol";
import "@openzeppelin/contracts@4.8.0/utils/Strings.sol";

contract NFTzen is ERC721, ERC721Enumerable, ERC721Burnable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    Counters.Counter private _tokenIdCounter;
    uint256[] private allTokenIds;

    mapping(uint256 => uint256) public tokenIdToLastFed;


    constructor() ERC721("NFTzen", "Zen") {}

    function mint() public returns (uint256){
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(msg.sender, tokenId);
        allTokenIds.push(tokenId);
        tokenIdToLastFed[tokenId] = block.timestamp;
        return tokenId;
    }

    function feed(uint256 tokenId) public returns (string memory){
        uint256 newLastFed =  block.timestamp;

        require(_exists(tokenId), "Please use an existing token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token to feed it");
        
        tokenIdToLastFed[tokenId] = newLastFed;
        return newLastFed.toString();
    }

    function burn(uint256 tokenId) public override {
        require(_exists(tokenId), "Please use an existing token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token to feed it");
        removeByValue(tokenId);
        _burn(tokenId);
    }

    function burnToken(uint256 tokenId) public {
        removeByValue(tokenId);
        _burn(tokenId);
    }

    function findElement(uint value) private view returns(uint) {
        uint i = 0;
        while (allTokenIds[i] != value) {
            i++;
        }
        return i;
    }

    function removeByValue(uint value) private {
        uint i = findElement(value);
        removeByIndex(i);
    }

    function removeByIndex(uint i) private {
        while (i<allTokenIds.length-1) {
            allTokenIds[i] = allTokenIds[i+1];
            i++;
        }
        allTokenIds.pop();
    }

    function getLastFed(uint256 tokenId) public view returns (string memory) {
        uint256 lastFed = tokenIdToLastFed[tokenId];
        return lastFed.toString();
    }

    function getTotalCount() public view returns (string memory) {
        uint256 totalCount =  ERC721Enumerable.totalSupply();
        return totalCount.toString();
    }

    function getAllTokenIds() public view returns (uint256[] memory) {
        return allTokenIds;
    }

    function getAllTokens() public view returns (uint256[] memory){
        uint256 length = allTokenIds.length;
        uint256[] memory itemList = new uint256[](length);

        for (uint256 i=0; i < length; i++){
            uint256 tokenId = allTokenIds[i];
            uint256 lastFed = tokenIdToLastFed[tokenId];
            itemList[i] = lastFed;
        }
        return itemList;    
    }


    function _beforeTokenTransfer(address from, address to, uint256 tokenId, uint256 batchSize)
        internal
        override(ERC721, ERC721Enumerable)
    {
        super._beforeTokenTransfer(from, to, tokenId, batchSize);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC721, ERC721Enumerable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}
