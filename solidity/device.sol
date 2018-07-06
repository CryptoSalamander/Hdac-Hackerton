pragma solidity ^0.4.0;

import "./home.sol";
import "./safemath.sol";

contract device is home {
    using SafeMath for uint;
    struct Device {
        address deviceAddress;
        bool state;
        string name;
        string deviceType;
        uint startTime;
        uint endTime;
        uint usageTime;
        uint fee;
        uint homeIndex;
        bool isOwners;
    }

    mapping(address => Device) devices;

    function getDevice(address _deviceAddress) public constant returns (
        bool _state,
        string _name,
        string _type,
        uint _startTime,
        uint _endTime,
        uint _usageTime,
        uint _fee,
        uint _homeIndex)
    {
        _state = devices[_deviceAddress].state;
        _name = devices[_deviceAddress].name;
        _type = devices[_deviceAddress].deviceType;
        _startTime = devices[_deviceAddress].startTime;
        _endTime = devices[_deviceAddress].endTime;
        _usageTime = devices[_deviceAddress].usageTime;
        _fee = devices[_deviceAddress].fee;
        _homeIndex = devices[_deviceAddress].homeIndex;
    }

    function addDevice(uint _homeIndex, address _deviceAddress, string _name, string _type, uint _fee) public returns (bool) {
        if(homes[_homeIndex].homeOwner != msg.sender && homes[_homeIndex].homeNet.admin != msg.sender)
        {
            return false;
        }
        homes[_homeIndex].homeNet.permittedDevice.push(_deviceAddress);
        if(msg.sender == homes[_homeIndex].homeOwner)
        {
            devices[_deviceAddress] = Device(_deviceAddress, false, _name, _type, 0, 0, 0, _fee, _homeIndex,true);
        }
        else
        {
            devices[_deviceAddress] = Device(_deviceAddress, false, _name, _type, 0, 0, 0, homes[_homeIndex].homeNet.defaultfee, _homeIndex,false);
        }
        homes[_homeIndex].homeNet.numDevice++;
        return true;
    }

    function onDevice(uint _homeIndex, address _deviceAddress) public returns(bool) {
        bool result = false;
        for(uint i; i < homes[_homeIndex].homeNet.numDevice; i++)
        {
            if(homes[_homeIndex].homeNet.permittedDevice[i] == _deviceAddress)
            {
                for(uint j; j < homes[_homeIndex].homeNet.numPermittedUser; j++)
                {
                    if(homes[_homeIndex].homeNet.permittedUser[j] == msg.sender && devices[_deviceAddress].state == false)
                    {
                        result = true;
                        devices[_deviceAddress].state = true;
                        devices[_deviceAddress].startTime = now;
                    }
                }
            }
        }
        return result;
    }

    function offDevice(uint _homeIndex, address _deviceAddress) public returns(bool){
        bool result = false;
        for(uint i; i < homes[_homeIndex].homeNet.numDevice; i++)
        {
            if(homes[_homeIndex].homeNet.permittedDevice[i] == _deviceAddress)
            {
                for(uint j; j < homes[_homeIndex].homeNet.numPermittedUser; j++)
                {
                    if(homes[_homeIndex].homeNet.permittedUser[j] == msg.sender && devices[_deviceAddress].state == true)
                    {
                        result = true;
                        devices[_deviceAddress].state = false;
                        devices[_deviceAddress].endTime = now;
                        devices[_deviceAddress].usageTime = devices[_deviceAddress].usageTime.add(devices[_deviceAddress].endTime.sub(devices[_deviceAddress].startTime));
                    }
                }
            }
        }
        return result;
    }

    function initializeDevices(uint _homeIndex) internal returns(bool){
        uint counter = 0;
        for(uint i = 0; i < homes[_homeIndex].homeNet.numDevice; i++)
        {
            if(devices[homes[_homeIndex].homeNet.permittedDevice[i]].isOwners == false)
            {
                counter = counter.add(1);
                delete homes[_homeIndex].homeNet.permittedDevice[i];
            }
        }
        homes[_homeIndex].homeNet.numDevice = homes[_homeIndex].homeNet.numDevice.sub(counter);
        return true;
    }

}
