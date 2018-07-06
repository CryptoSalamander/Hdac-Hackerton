/// This is made for hdac Hackerton in 2018.
/// Made by Team Block In
/// Ver 1.5
pragma solidity ^0.4.0;

import "./permission.sol";

contract hdac is Permission {
    function constuctor() public {
        numHomes = 1;
        balance = 0;
        contractOwner = msg.sender;
    }
}
