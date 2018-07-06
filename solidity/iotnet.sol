pragma solidity ^0.4.0;

contract iotnet {
    struct IoTnet {
        address admin;
        address[] permittedUser;
        address[] permittedDevice;
        uint numDevice;
        uint numPermittedUser;
        uint defaultfee;
    }
}
