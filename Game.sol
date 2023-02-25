// SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

import "./Gold.sol"; //ERC20
import "./Cow.sol"; //ERC721 
import "./Items.sol"; //ERC1155

contract Game {

    Items items;
    Gold gold;
    Cow cow;

    constructor(address _itemsAddress, address _goldAddress, address _cowAddress) {
        items = Items(_itemsAddress);
        gold = Gold(_goldAddress);
        cow = Cow(_cowAddress);


        addItem(0, "domates",  2000000000000000000);
        addItem(1, "peynir",  3000000000000000000);
        addItem(2, "ekmek",  4000000000000000000);

        addItem(3, "ekmekarasi",  10000000000000000000);
    }


    struct Player {
        uint ID;
        address playerAddress;
        uint stakeTime;
    }

    struct Item {
        uint ID;
        string name;
        uint price;
    }


    mapping(address => Player) public players;

    mapping(uint => Item) public idToItems;

    uint playerCount = 0;

    function register() public payable {
        require( players[msg.sender].ID ==0, "you are already registered");
        require( msg.value >= 10000000000000000000 );
        Player memory player;
        playerCount++;
        player.ID = playerCount;
        gold.mint(msg.sender, 10000000000000000000);
        player.playerAddress = msg.sender;
        players[msg.sender] = player;
    }

    function addItem(uint _id, string memory _name, uint _price ) private {
        idToItems[_id] = Item(_id, _name, _price);
    }

    function buyItem(uint _id, uint _amount) public {
        uint totalPrice = idToItems[_id].price * _amount;
        require(gold.balanceOf(msg.sender) >= totalPrice, "you have not got enough money");
        gold.burn(msg.sender, totalPrice);

        items.mint(msg.sender, _id, _amount, "");
    }

    function sellItem(uint _id, uint _amount) public {
        require(items.balanceOf(msg.sender, _id) >=  _amount );
        items.burn(msg.sender, _id, _amount);

        gold.mint( msg.sender, idToItems[_id].price * _amount );

    }

    function prepareSandwich() public {
        require(players[msg.sender].stakeTime == 0);
        require(
            items.balanceOf(msg.sender, 0) >= 1 &&  
            items.balanceOf(msg.sender, 1) >= 1 &&  
            items.balanceOf(msg.sender, 2) >= 1, "your ingredients are insufficientS"
        );

        items.burn(msg.sender, 0, 1);
        items.burn(msg.sender, 1, 1);
        items.burn(msg.sender, 2, 1);

        players[msg.sender].stakeTime = block.timestamp;

    }

    function takeSandwich() public {
        require( players[msg.sender].stakeTime + 30 seconds >= block.timestamp, "sandwich is not ready");

        items.mint(msg.sender, 3, 1, "");

        players[msg.sender].stakeTime = 0;

    }

    function milkCow(uint _id) public {
        require( cow.viewMilkingTime(_id) + 6 hours >= block.timestamp );
        require( cow.ownerOf(_id) == msg.sender);
        cow.setMilkingTime(_id, block.timestamp);

        items.mint(msg.sender, 1, 1, "");
    }

    function buyCow() public {
        gold.burn(msg.sender, 10000000000000000000);
        cow.safeMint(msg.sender);

    }

    function deposit() public payable {
        require(msg.value > 0);
        gold.mint(msg.sender, msg.value);
    }

    function withdraw(uint _amount) public {
        require(gold.balanceOf(msg.sender) >=  _amount );
        gold.burn(msg.sender,_amount );
        payable(msg.sender).transfer(_amount);
    }

}
