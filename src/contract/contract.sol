// SPDX-License-Identifier: MIT
//can check a users owned nfts
pragma solidity ^0.8.9;

import "@openzeppelin/contracts@4.8.0/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC721/extensions/ERC721Burnable.sol";
import "@openzeppelin/contracts@4.8.0/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts@4.8.0/utils/Counters.sol";
import "@openzeppelin/contracts@4.8.0/utils/Strings.sol";

contract NFTzen is ERC721, ERC721Enumerable, ERC721Burnable {
    using Counters for Counters.Counter;
    using Strings for uint256;

    struct Metadata {
        uint256 tokenId;
        uint256 lastFed;
        uint256 maxTime;
        uint256 animal;  
    }

    Counters.Counter private _tokenIdCounter;
    uint256[] private allTokenIds;
    mapping(uint256 => Metadata) public tokenMetadata;

    //constants
    uint maxSupply = 4;
    uint256 minTime = 86400;
    uint256 timeRange = 4;
    uint256 maxAnimals = 4;


    constructor() ERC721("NFTzen", "Zen") {}

    //key methods
    function mint() public returns (uint256){
        uint256 length = allTokenIds.length;
        require(length < maxSupply, "Max NFTs reached already");

        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();

        _safeMint(msg.sender, tokenId);
        allTokenIds.push(tokenId);

        uint256 currentTimestamp = block.timestamp;
        uint256 maxTime = minTime + (random(timeRange)*minTime);
        uint256 animal = random(maxAnimals);

        tokenMetadata[tokenId] = Metadata (tokenId, currentTimestamp, maxTime, animal);

        return tokenId;
    }

    function feed(uint256 tokenId) public returns (string memory){
        uint256 newLastFed =  block.timestamp;

        require(_exists(tokenId), "Please use an existing token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token to feed it");
        
        tokenMetadata[tokenId].lastFed = newLastFed;
        return newLastFed.toString();
    }

    function clean(uint256 tokenId) public returns (uint256){
        uint256 currentTime = block.timestamp;

        uint256 timeDiff = currentTime - tokenMetadata[tokenId].lastFed;
        if(timeDiff > tokenMetadata[tokenId].maxTime){
            removeByValue(tokenId);
            _burn(tokenId);
        }
        return timeDiff;
    }

    function getAllTokens() public view returns (Metadata[] memory){
        uint256 length = allTokenIds.length;
        Metadata[] memory itemList = new Metadata[](length);

        for (uint256 i=0; i < length; i++){
            uint256 tokenId = allTokenIds[i];
            itemList[i] = tokenMetadata[tokenId];
        }
        return itemList;    
    }

    function getAllOwnedTokenIDs() public view returns (uint256[] memory){
        uint256 length = balanceOf(msg.sender);
        uint256[] memory itemList = new uint256[](length);

        for (uint256 i=0; i < length; i++){
            uint256 tokenId = tokenOfOwnerByIndex(msg.sender, i);
            itemList[i] = tokenId;
        }
        return itemList;    
    }

    //supporting methods
    function burn(uint256 tokenId) public override {
        require(_exists(tokenId), "Please use an existing token");
        require(ownerOf(tokenId) == msg.sender, "You must own this token to feed it");

        removeByValue(tokenId);
        _burn(tokenId);
    }

    function getLastFed(uint256 tokenId) public view returns (string memory) {
        require(_exists(tokenId), "Please use an existing token");

        uint256 lastFed = tokenMetadata[tokenId].lastFed;
        return lastFed.toString();
    }

    function getTotalCount() public view returns (string memory) {
        uint256 totalCount =  ERC721Enumerable.totalSupply();
        return totalCount.toString();
    }

    function getAllTokenIds() public view returns (uint256[] memory) {
        return allTokenIds;
    }

    //utilities
    function random(uint range) public view returns(uint){
        return uint(keccak256(abi.encodePacked(block.timestamp,block.difficulty,msg.sender))) % range;
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
