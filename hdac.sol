/// This is made for hdac Hackerton in 2018.
/// Made by Team Block In
/// Ver 1.3
pragma solidity ^0.4.0;
contract hdac{
    
   struct IoTnet{
       address Admin;
       address[] PermittedUser;
       address[] PermittedDevice;
       uint numDevice;
       uint numPermittedUser;
   }
   
   struct Device{
       address DeviceAddress;
       bool State;
       string Name;
       string Type;
       uint StartTime;
       uint EndTime;
       uint UsageTime;
       uint Fee;
       uint HomeIndex;
   }
   
   struct Home{
       address HomeOwner;
       IoTnet HomeNet;
       uint Index;
       bool OnMarket;
       uint Price;
       uint CheckinTime;
       uint CheckoutTime;
       uint UsageTime;
   }
   
   struct Customer{
       address CustomerAddress;
       uint Deposit;
       uint TotalPrice;
   }
   
   mapping(uint => Home) homes;
   mapping(address => Device) devices;
   mapping(address => Customer) customers;
   uint public numHomes;
   uint public Balance;
   address ContractOwner;

   function Constuctor() public {
   numHomes = 1;
   Balance = 0;
   ContractOwner = msg.sender;
   }
   
   function () payable public {
       customers[msg.sender] = Customer(msg.sender,msg.value,0);
       Balance += msg.value;
   }
   
   function GetHour(uint _TimeStamp) public pure returns (uint) 
   {
       return uint(_TimeStamp / 60 / 60);
   }
   
   function GetMinute(uint _TimeStamp) public pure returns (uint)
   {
       return uint(_TimeStamp / 60);
   }
   
   function RegistHome(address _HomeOwner) public {
       if(msg.sender != ContractOwner)
       {
           return;
       }
       homes[numHomes] = Home(_HomeOwner,IoTnet(0,new address[](0),new address[](0),0,0),numHomes,false,0,0,0,0);
   }
   
   function OnSale(uint _HomeIndex, uint _Price) public
   {
       if(homes[_HomeIndex].HomeOwner != msg.sender)
       {
           return;
       }
       homes[_HomeIndex].OnMarket = true;
       homes[_HomeIndex].Price = _Price;
   }
   
   function AddDevice(uint _HomeIndex, address _DeviceAddress, string _Name, string _Type, uint _Fee) public {
       if(homes[_HomeIndex].HomeOwner != msg.sender)
       {
           return;
       }       
       homes[_HomeIndex].HomeNet.PermittedDevice.push(_DeviceAddress);
       devices[_DeviceAddress] = Device(_DeviceAddress,false,_Name,_Type,0,0,0,_Fee,_HomeIndex);
       homes[_HomeIndex].HomeNet.numDevice++;
   }
   
   function GiveAdmin(uint _HomeIndex, address _To) public {
       if(homes[_HomeIndex].HomeOwner != msg.sender)
       {
           return;
       }
       homes[_HomeIndex].HomeNet.Admin = _To;
       homes[_HomeIndex].HomeNet.PermittedUser.push(_To);
       homes[_HomeIndex].HomeNet.numPermittedUser++;
   }
   
   function DelegatePermission(uint _HomeIndex, address _To) public {
       if(homes[_HomeIndex].HomeNet.Admin != msg.sender && homes[_HomeIndex].HomeOwner != msg.sender)
       {
           return;
       }
       homes[_HomeIndex].HomeNet.PermittedUser.push(_To);
       homes[_HomeIndex].HomeNet.numPermittedUser++;
   }
   
   function Checkin(uint _HomeIndex, address _To) public {
       /*if(homes[_HomeIndex].HomeOwner != msg.sender)
       {
           return;
       }*/
       require(homes[_HomeIndex].HomeOwner == msg.sender);
       if(homes[_HomeIndex].OnMarket == false)
       {
           return;
       }
       if(customers[_To].Deposit < 3 ether)
       {
           return;
       }
       DelegatePermission(_HomeIndex,_To);
       homes[_HomeIndex].OnMarket = false;
       homes[_HomeIndex].CheckinTime = now;
   }
   
   function Checkout(uint _HomeIndex, address _CustomerAddress) payable public {
       if(homes[_HomeIndex].HomeOwner != msg.sender)
       {
           return;
       }
       homes[_HomeIndex].CheckoutTime = now;
       homes[_HomeIndex].UsageTime = homes[_HomeIndex].CheckoutTime - homes[_HomeIndex].CheckinTime;
       for(uint i = 0; i < homes[_HomeIndex].HomeNet.numDevice; i++)
       {
           customers[_CustomerAddress].TotalPrice += devices[homes[_HomeIndex].HomeNet.PermittedDevice[i]].UsageTime * devices[homes[_HomeIndex].HomeNet.PermittedDevice[i]].Fee;
       }
       customers[_CustomerAddress].TotalPrice += homes[_HomeIndex].UsageTime * homes[_HomeIndex].Price;
       DoPay(_CustomerAddress,_HomeIndex);
       Initialize(_HomeIndex);
   }
   
   function DoPay(address _CustomerAddress,uint _HomeIndex) payable public {
       homes[_HomeIndex].HomeOwner.transfer(customers[_CustomerAddress].TotalPrice);
       _CustomerAddress.transfer(customers[_CustomerAddress].Deposit - customers[_CustomerAddress].TotalPrice);
       Balance = Balance - customers[_CustomerAddress].Deposit;
   }
   
   function DeviceOn(uint _HomeIndex,address _DeviceAddress) public{
       for(uint i; i < homes[_HomeIndex].HomeNet.numDevice; i++)
       {
           if(homes[_HomeIndex].HomeNet.PermittedDevice[i] == _DeviceAddress)
           {
               for(uint j; j < homes[_HomeIndex].HomeNet.numPermittedUser; j++)
               {
                   if(homes[_HomeIndex].HomeNet.PermittedUser[j] == msg.sender && devices[_DeviceAddress].State == false)
                   {
                      devices[_DeviceAddress].State = true;
                      devices[_DeviceAddress].StartTime = now;
                   }
               }
           }
       }
   }
   
   function DeviceOff(uint _HomeIndex, address _DeviceAddress) public{
       for(uint i; i < homes[_HomeIndex].HomeNet.numDevice; i++)
       {
           if(homes[_HomeIndex].HomeNet.PermittedDevice[i] == _DeviceAddress)
           {
               for(uint j; j < homes[_HomeIndex].HomeNet.numPermittedUser; j++)
               {
                   if(homes[_HomeIndex].HomeNet.PermittedUser[j] == msg.sender && devices[_DeviceAddress].State == true)
                   {
                      devices[_DeviceAddress].State = false;
                      devices[_DeviceAddress].EndTime = now;
                      devices[_DeviceAddress].UsageTime += uint(devices[_DeviceAddress].EndTime - devices[_DeviceAddress].StartTime);
                   }
               }
           }
       }       
   }
   
   function Initialize(uint _HomeIndex) public {
       homes[_HomeIndex].HomeNet.Admin = 0;
       homes[_HomeIndex].HomeNet.PermittedUser = new address[](0);
       homes[_HomeIndex].HomeNet.numPermittedUser = 0;
       homes[_HomeIndex].OnMarket = false;
       homes[_HomeIndex].CheckinTime = 0;
       homes[_HomeIndex].CheckoutTime = 0;
       homes[_HomeIndex].UsageTime = 0;
   }
   
   function GetHome(uint _HomeIndex) public constant returns(address _HomeOwner, bool _OnMarket, uint _Price, uint _CheckinTime, uint _CheckoutTime, uint _UsageHour, uint _UsageMinute){
       _HomeOwner = homes[_HomeIndex].HomeOwner;
       _OnMarket = homes[_HomeIndex].OnMarket;
       _Price = homes[_HomeIndex].Price;
       _CheckinTime = homes[_HomeIndex].CheckinTime;
       _CheckoutTime = homes[_HomeIndex].CheckoutTime;
       _UsageHour = GetHour(_CheckoutTime - _CheckinTime);
       _UsageMinute = GetMinute(_CheckoutTime - _CheckinTime);
   }
   
   function GetDevice(address _DeviceAddress) public constant returns (bool _State, string _Name, string _Type, uint _StartTime, uint _EndTime, uint _UsageTime, uint _Fee, uint _HomeIndex)
   {
       _State = devices[_DeviceAddress].State;
       _Name = devices[_DeviceAddress].Name;
       _Type = devices[_DeviceAddress].Type;
       _StartTime = devices[_DeviceAddress].StartTime;
       _EndTime = devices[_DeviceAddress].EndTime;
       _UsageTime = devices[_DeviceAddress].UsageTime;
       _Fee = devices[_DeviceAddress].Fee;
       _HomeIndex = devices[_DeviceAddress].HomeIndex;
   }
   
   function GetCustomer(address _CustomerAddress) public constant returns (uint _Deposit, uint _TotalPrice) {
       _Deposit = customers[_CustomerAddress].Deposit;
       _TotalPrice = customers[_CustomerAddress].TotalPrice;
   }
   
   function GetIoTnet(uint _HomeIndex) public constant returns (address _Admin, address[] _PermittedUser, address[] _PermittedDevice, uint _numDevice, uint _numPermittedUser)
   {
       _Admin = homes[_HomeIndex].HomeNet.Admin;
       _PermittedUser = homes[_HomeIndex].HomeNet.PermittedUser;
       _PermittedDevice = homes[_HomeIndex].HomeNet.PermittedDevice;
       _numDevice = homes[_HomeIndex].HomeNet.numDevice;
       _numPermittedUser = homes[_HomeIndex].HomeNet.numPermittedUser;
   }


}
