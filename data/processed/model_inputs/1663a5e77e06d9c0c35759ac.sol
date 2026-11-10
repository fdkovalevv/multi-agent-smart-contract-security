contract C {
    uint[] public amounts;
    address payable[] addresses;
    address payable owner;
    bool[] public flags;
    
    constructor() public{
        owner = msg.sender;
    }

    function collect(address payable to) external payable {
        amounts.push(msg.value);
        addresses.push(to);
    }

    function pay() external {
        uint length = amounts.length;

        for (uint i = 0; i < length; i++) {
            bool flag = addresses[i].send(amounts[i]);
            if(flag)
                flags.push(addresses[i].send(amounts[i]));
        }
    }
    
                                                                         
                                           
    function returnMoney() external{
        require(msg.sender == owner);
        require(amounts.length == flags.length && addresses.length == flags.length);
        selfdestruct(owner);
    }
}