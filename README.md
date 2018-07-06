# Block In
## testRPC
### before run this project, make sure running testrpc on background 
URL : localhost:8545
- install via npm (Make sure you habve Node.js)

``` shell
npm install -g ethereumjs-testrpc
```
- execute via terminal
``` shell
$ testrpc #execute default
$ testrpc -l 1000 #execute with setting gaslimit
```

## Run this Project
- install dependencies
``` shell
npm i
```

- run
``` shell
npm start
```

URL : http://localhost:1356

### 솔리디티 정의된 인터페이스 보기
``` shell
/block-in/api/interface?name=hdac
```

``` json
{
"methods": [
"getDevice",
"0x00d55318",
"getDevice(address)",
"addDevice",
"0x0a342e8d",
"addDevice(uint256,address,string,string,uint256)",
"doPay",
"0x0bfd588a",
"doPay(address,uint256)",
"onDevice",
"0x2781ec46",
"onDevice(uint256,address)",
"getHome",
"0x616d5b6b",
"getHome(uint256)",
"delegatePermission",
"0x7ff30678",
"delegatePermission(uint256,address)",
"giveAdmin",
"0xadfcb641",
"giveAdmin(uint256,address)",
"balance",
"0xb69ef8a8",
"balance()",
"getCustomer",
"0xcb949e51",
"getCustomer(address)",
"contractOwner",
"0xce606ee0",
"contractOwner()",
"getIoTnet",
"0xd88cbbf0",
"getIoTnet(uint256)",
"offDevice",
"0xdc8ae488",
"offDevice(uint256,address)",
"constuctor",
"0xdfe4858a",
"constuctor()",
"checkout",
"0xe19c97d3",
"checkout(uint256,address)",
"numHomes",
"0xea6564f7",
"numHomes()",
"transferOwnership",
"0xf2fde38b",
"transferOwnership(address)",
"onSale",
"0xf5379db8",
"onSale(uint256,uint256,uint256,uint256)",
"checkin",
"0xf7aad18e",
"checkin(uint256,address)",
"refund",
"0xfa89401a",
"refund(address)",
"registHome",
"0xff77ebf9",
"registHome(address)"
],
"code": 200
}
```
### 솔리디티 바로테스트 하기
``` shell
# HTTP Method: POST 

/block-in/api/interface/call
/block-in/api/interface/send
```

- example request body
``` json
{
    "name" : "hdac",
    "method": "GetMinute",
/*  send 의 경우   */ 
/*  "gas": 1000, */
/*       추가     */
    "from": "0x98bcD3D00454BEeCAf45Cc204F68962F7C153Cfd",
    "param": [
        23456789    // 주의:  method에 따라 순서 잘 맞추어서 넣어야함!!
    ]
}
```
- response 
``` json
//success
{
    "ret": "390946", // ret 에 solidity에서 call하고 나온값 반환
    "code": 200
}
```




### example api
``` shell
/block-in/api/contract/block-in?name=hdac
```

- request query (GET method)
    - name : {contract name}

- response (JSON)
    - code: {response code}
    - address: {contract address},
    - abi: {compiled contract abi}