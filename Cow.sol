// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract Cow is ERC721, Ownable {
    using Counters for Counters.Counter;

    Counters.Counter private _tokenIdCounter;

    mapping(uint => uint) public lastMilkedTime;

    constructor() ERC721("Cow", "Cow") {}

    function safeMint(address to) public onlyOwner {
        uint256 tokenId = _tokenIdCounter.current();
        _tokenIdCounter.increment();
        _safeMint(to, tokenId);
    }

    function setMilkingTime(uint _id, uint _time) public onlyOwner {
        lastMilkedTime[_id] = _time;
    }

    function viewMilkingTime(uint _id) public view returns(uint) {
        return lastMilkedTime[_id];
    }


}
