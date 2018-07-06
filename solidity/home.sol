pragma solidity ^0.4.0;

import "./iotnet.sol";
import "./ownable.sol";
import "./time.sol";
import "./safemath.sol";

contract home is iotnet, Ownable {
    using Time for uint;
    using SafeMath for uint;

    struct Home {
        address homeOwner;
        IoTnet homeNet;
        uint index;
        bool isOnMarket;
        uint price;
        uint deposit;
        uint checkinTime;
        uint checkoutTime;
        uint usageTime;
    }


    mapping(address => uint) homelist;
    mapping(uint => Home) homes;
    uint public numHomes;

    function registHome(address _HomeOwner) public returns(bool) {
        IoTnet memory newIoTnet = IoTnet(0,new address[](0), new address[](0), 0, 0, 0);
        homes[numHomes] = Home(_HomeOwner, newIoTnet, numHomes, false, 0, 0, 0, 0, 0);
        homelist[_HomeOwner] = numHomes;
        numHomes++;
        return true;
    }

    function onSale(uint _homeIndex, uint _price, uint _deposit, uint _defaultfee) public returns(bool)
    {
        homes[_homeIndex].isOnMarket = true;
        homes[_homeIndex].price = _price;
        homes[_homeIndex].deposit = _deposit;
        homes[_homeIndex].homeNet.defaultfee = _defaultfee;
        return true;
    }

    function initialize(uint _homeIndex) internal {
        homes[_homeIndex].homeNet.admin = 0;
        homes[_homeIndex].homeNet.permittedUser = new address[](0);
        homes[_homeIndex].homeNet.numPermittedUser = 0;
        homes[_homeIndex].isOnMarket = false;
        homes[_homeIndex].checkinTime = 0;
        homes[_homeIndex].checkoutTime = 0;
        homes[_homeIndex].usageTime = 0;
    }



    function getHome(uint _homeIndex) public view returns (
        address _homeOwner,
        bool _isOnMarket,
        uint _price,
        uint _deposit,
        uint _checkinTime,
        uint _checkoutTime,
        uint _usageHour,
        uint _usageMinute)
    {
        _homeOwner = homes[_homeIndex].homeOwner;
        _isOnMarket = homes[_homeIndex].isOnMarket;
        _price = homes[_homeIndex].price;
        _deposit = homes[_homeIndex].deposit;
        _checkinTime = homes[_homeIndex].checkinTime;
        _checkoutTime = homes[_homeIndex].checkoutTime;
        if(_checkinTime == 0)
        {
            _usageHour = 0;
            _usageMinute = 0;
        }
        else
        {
            _usageHour = now.sub(_checkinTime).getHour();
            _usageMinute = now.sub(_checkinTime).getMinute();
        }
    }

    function getHomelist(address _homeOwner) public constant returns(uint _homeIndex)
    {
        _homeIndex = homelist[_homeOwner];
    }

    function getIoTnet(uint _homeIndex) public constant returns
    (
    address _admin,
    address[] _permittedUser,
    address[] _permittedDevice,
    uint _numDevice,
    uint _numPermittedUser,
    uint _defaultfee)
    {
        IoTnet memory returnIoTnet = homes[_homeIndex].homeNet;
        _admin = returnIoTnet.admin;
        _permittedUser = returnIoTnet.permittedUser;
        _permittedDevice = returnIoTnet.permittedDevice;
        _numDevice = returnIoTnet.numDevice;
        _numPermittedUser = returnIoTnet.numPermittedUser;
        _defaultfee = returnIoTnet.defaultfee;
    }
}
