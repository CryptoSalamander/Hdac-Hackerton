pragma solidity ^0.4.0;

contract customer {
    struct Customer {
        address customerAddress;
        string name;
        string phone;
        uint deposit;
        uint totalPrice;
        bool isCheckedin;
    }

    mapping(address => Customer) customers;

    function registCustomer(string _name, string _phone) public returns(bool)
    {
        bytes memory test;
        string memory myname;
        myname = customers[msg.sender].name;
        test = bytes(myname);
        if(test.length != 0)
        {
            return false;//Already Exist!
        }
        customers[msg.sender] = Customer(msg.sender,_name,_phone,0,0,false);
        return true;
    }

    function getCustomer(address _customerAddress) public constant returns (
        string _name,
        string _phone,
        uint _deposit,
        uint _totalPrice,
        bool _isCheckedin)
    {
        _name = customers[_customerAddress].name;
        _phone = customers[_customerAddress].phone;
        _deposit = customers[_customerAddress].deposit;
        _totalPrice = customers[_customerAddress].totalPrice;
        _isCheckedin = customers[_customerAddress].isCheckedin;
    }
}
