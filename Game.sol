// SPDX-License-Identifier: MIT

pragma solidity >=0.7.0 <0.9.0;

import "./RewardToken.sol";
import "./Items.sol";
import "./Machine.sol";


contract Game {

    Gold public gold;
    Items public items;
    Machine public machine;

    constructor(address _goldAddress, address _itemsAddress, address _machineAddress) {
        gold = Gold(_goldAddress);
        items = Items(_itemsAddress);
        machine = Machine(_machineAddress);

        addItem("domates", 0, 1000000000000000000);
        addItem("peynir", 1, 2000000000000000000);
        addItem("ekmek", 2, 1000000000000000000);
        addItem("ekmekarasi", 3, 7000000000000000000);
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

    uint playerCount = 1;

    mapping(address => Player) public players;
    mapping(uint => Item) public idToItems;

    function investMoney() public payable {
        require(msg.value > 0);
        gold.mint(msg.sender, msg.value);
    }

    function startGame() public {
        require(players[msg.sender].ID == 0, "you have already registered");
        gold.burnFrom(msg.sender, 5000000000000000000);
        Player memory player;
        player.ID = playerCount;
        player.playerAddress = msg.sender;
        players[msg.sender] = player;
    }

    function buyItem(uint _id, uint _amount) public {
        require(gold.balanceOf(msg.sender) >= _amount * idToItems[_id].price, "you have not got enough gold" );
        gold.burnFrom(msg.sender, _amount * idToItems[_id].price );
        items.mint(msg.sender, _id, _amount, "");
    }

    function sellItem(uint _id, uint _amount) public {
        require( items.balanceOf(msg.sender, _id) >= _amount );
        items.burn(msg.sender, _id, _amount);
        gold.mint(msg.sender, _amount * idToItems[_id].price );
    }


    function prepareSandwich() public {
        require(players[msg.sender].stakeTime == 0 );
        require( 
            items.balanceOf(msg.sender, 0) >= 1
            && items.balanceOf(msg.sender, 1) >= 2
            && items.balanceOf(msg.sender, 2) >= 1
        );
        items.burn(msg.sender, 0, 1);
        items.burn(msg.sender, 1, 2);
        items.burn(msg.sender, 2, 1);
        players[msg.sender].stakeTime = block.timestamp;
    }

    function takeSandwich() public {
        if(  machine.balanceOf(msg.sender) >= 1  && block.timestamp >= players[msg.sender].stakeTime + 6 hours ) {
            revert("not yet");
        } else if( block.timestamp >=  players[msg.sender].stakeTime + 12 hours) {
            revert("not yet");
        }
        items.mint(msg.sender, 3, 1, "");
        players[msg.sender].stakeTime = 0;
    }

    function buyMachine() public {
        gold.burnFrom(msg.sender, 5000000000000000000);
        machine.safeMint(msg.sender);
    }

    function addItem(string memory _name, uint _id, uint _price) private {
        Item memory item;
        item.ID = _id;
        item.name = _name;
        item.price = _price;
        idToItems[_id] = item;
    }


}

