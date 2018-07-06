pragma solidity ^0.4.0;

library Time {
    function getHour(uint _TimeStamp) internal pure returns (uint)
    {
        return uint(_TimeStamp / 60 / 60);
    }

    function getMinute(uint _TimeStamp) internal pure returns (uint)
    {
        return uint(_TimeStamp / 60);
    }
}
