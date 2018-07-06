pragma solidity ^0.4.0;

import "./home.sol";
import "./customer.sol";
import "./device.sol";
import "./safemath.sol";

contract Permission is home, customer, device {
    using SafeMath for uint;
    function () payable public {
        if(msg.sender == contractOwner)
        {
            balance = balance.add(msg.value);
        }
        else
        {
            if(bytes(customers[msg.sender].name).length == 0)
            {
                return;
            }
            customers[msg.sender].deposit = msg.value;
            balance = balance.add(msg.value);
        }
    }

    function giveAdmin(uint _homeIndex, address _to) public returns(bool){
        if(homes[_homeIndex].homeOwner != msg.sender)
        {
            return false;
        }
        homes[_homeIndex].homeNet.admin = _to;
        homes[_homeIndex].homeNet.permittedUser.push(_to);
        homes[_homeIndex].homeNet.numPermittedUser++;
        return true;
    }

    function delegatePermission(uint _homeIndex, address _to) internal returns(bool){
        homes[_homeIndex].homeNet.permittedUser.push(_to);
        homes[_homeIndex].homeNet.numPermittedUser++;
        return true;
    }

    function checkin(uint _homeIndex) public returns(bool) {
        if(homes[_homeIndex].isOnMarket == false)
        {
            return false;
        }
        if(customers[msg.sender].deposit < homes[_homeIndex].deposit.mul(1 ether))
        {
            return false;
        }
        giveAdmin(_homeIndex,msg.sender);
        delegatePermission(_homeIndex, msg.sender);
        homes[_homeIndex].isOnMarket = false;
        homes[_homeIndex].checkinTime = now;
        customers[msg.sender].isCheckedin = true;
        return true;
    }

    function checkout(uint _homeIndex) payable public returns(bool){
        if(homes[_homeIndex].homeNet.admin != msg.sender)
        {
            return false;
        }
        require(customers[msg.sender].isCheckedin == true);
        homes[_homeIndex].checkoutTime = now;
        homes[_homeIndex].usageTime = homes[_homeIndex].checkoutTime.sub(homes[_homeIndex].checkinTime);
        for(uint i = 0; i < homes[_homeIndex].homeNet.numDevice; i++)
        {
            uint usageTime = devices[homes[_homeIndex].homeNet.permittedDevice[i]].usageTime;
            uint fee = devices[homes[_homeIndex].homeNet.permittedDevice[i]].fee;
            customers[msg.sender].totalPrice = customers[msg.sender].totalPrice.add(usageTime.mul(fee));
        }
        customers[msg.sender].totalPrice = customers[msg.sender].totalPrice.add(homes[_homeIndex].usageTime.mul(homes[_homeIndex].price));
        doPay(msg.sender, _homeIndex);
        initialize(_homeIndex);
        initializeDevices(_homeIndex);
        customers[msg.sender].isCheckedin = false;
        return true;
    }

    function doPay(address _customerAddress, uint _HomeIndex) payable public {
        require(customers[_customerAddress].totalPrice <= customers[_customerAddress].deposit);
        require(customers[_customerAddress].deposit <= balance);
        homes[_HomeIndex].homeOwner.transfer(customers[_customerAddress].totalPrice);
        if((customers[_customerAddress].deposit.sub(customers[_customerAddress].totalPrice)) > balance)
        {
            return;
        }
        _customerAddress.transfer(customers[_customerAddress].deposit.sub(customers[_customerAddress].totalPrice));
        balance = balance.sub(customers[_customerAddress].deposit);
        customers[_customerAddress].deposit = 0;
    }

    function refund(address _customerAddress) payable public {
        require(msg.sender == _customerAddress);
        require(customers[_customerAddress].isCheckedin == false);
        require(customers[_customerAddress].deposit < balance);
        _customerAddress.transfer(customers[_customerAddress].deposit);
    }
}
