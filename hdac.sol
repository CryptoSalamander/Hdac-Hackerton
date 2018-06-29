/// This is made for hdac Hackerton in 2018.
/// Made by Team Block In
/// Ver 0.1
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
   }
   
   struct Home{
       address HomeOwner;
       IoTnet HomeNet;
       uint Index;
       bool OnMarket;
       uint Price;
       uint CheckinTime;
       uint CheckoutTime;
   }
   
   mapping(uint => Home) homes;
   mapping(address => Device) devices;
   uint numHomes;
   address ContractOwner;

   function constuctor() public {
   numHomes = 1;
   ContractOwner = msg.sender;
   }
   
   function RegistHome(address _HomeOwner, uint _Price) public {
       if(msg.sender != ContractOwner)
       {
           return;
       }
       homes[numHomes] = Home(_HomeOwner,IoTnet(0,new address[](0),new address[](0),0,0),numHomes,false,_Price,0,0);
 //      homes[numHomes] = Home(_HomeOwner,IoTnets[_HomeOwner],numHomes,true,_Price);
   }
   
   function AddDevice(uint _HomeIndex, address _DeviceAddress, string _Name, string _Type, uint _Fee) public {
       if(homes[_HomeIndex].HomeOwner != msg.sender)
       {
           return;
       }       
       homes[_HomeIndex].HomeNet.PermittedDevice.push(_DeviceAddress);
       devices[_DeviceAddress] = Device(_DeviceAddress,false,_Name,_Type,0,0,0,_Fee);
       homes[_HomeIndex].HomeNet.numDevice++;
   }
   
   function GiveAdmin(uint _HomeIndex, address _To) public {
       if(homes[_HomeIndex].HomeOwner != msg.sender)
       {
           return;
       }
       homes[_HomeIndex].HomeNet.Admin = _To;
   }
   function DelegatePermission(uint _HomeIndex, address _To) public {
       if(homes[_HomeIndex].HomeNet.Admin != msg.sender)
       {
           return;
       }
       homes[_HomeIndex].HomeNet.PermittedUser.push(_To);
   }
   
   function Checkin(uint _HomeIndex, address _To) public {
       if(homes[_HomeIndex].OnMarket == false)
       {
           return;
       }
       DelegatePermission(_HomeIndex,_To);
       homes[_HomeIndex].OnMarket = false;
       homes[_HomeIndex].CheckinTime = now;
   }
   
   function Checkout(uint _HomeIndex) public {
       if(homes[_HomeIndex].HomeNet.Admin != msg.sender)
       {
           return;
       }
       
   }
   function GetHome(uint _HomeIndex) public constant returns(address _HomeOwner, bool _OnMarket, uint _Price){
       _HomeOwner = homes[_HomeIndex].HomeOwner;
       _OnMarket = homes[_HomeIndex].OnMarket;
       _Price = homes[_HomeIndex].Price;
   }
   
   function Initialize(uint _HomeIndex) public {
       
   }


}