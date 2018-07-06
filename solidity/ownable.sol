pragma solidity ^0.4.19;

contract Ownable {
    address public contractOwner;
    uint public balance;

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    function Ownable() public {
        contractOwner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == contractOwner);
        _;
    }

    function transferOwnership (address newOwner) public onlyOwner {
        require(newOwner != address(0));
        OwnershipTransferred(contractOwner, newOwner);
        contractOwner = newOwner;   
    }
}