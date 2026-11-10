contract C {
    uint[] amounts;
    address payable[] addresses;
    address payable owner;
    
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
            addresses[i].transfer(amounts[i]);
        }

                                                                                                                                                                                                                                                                                                                              
        delete amounts;
        delete addresses;
    }
    
    function returnMoney() external{
        require(msg.sender == owner);
        require(amounts.length == 0 && addresses.length == 0);
        selfdestruct(owner);
    }
}