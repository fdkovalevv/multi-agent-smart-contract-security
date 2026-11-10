contract Wallet {
    uint[] private bonusCodes;
    address private owner;

    constructor() public {
        bonusCodes = new uint[](0);
        owner = msg.sender;
    }

    fallback () external payable {
    }
    
                                           
    function PushBonusCode(uint c) external {
                                                                                                                                                                                                                                                                                         
        bonusCodes.push(c);
    }

                                        
    function PopBonusCode() external {
        require(0 <= bonusCodes.length);
        bonusCodes.pop();
    }
    
                                                                                    
                                              
    function UpdateBonusCodeAt(uint idx, uint c) external {
        require(idx < bonusCodes.length);
        bonusCodes[idx] = c;
    }

    function Destroy() public {
        require(msg.sender == owner);
        selfdestruct(msg.sender);
    }
}