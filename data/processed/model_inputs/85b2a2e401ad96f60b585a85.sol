contract gray_Wallet {
    uint[] private bonusCodes;
    address private owner;

    constructor(uint[] memory _bonusCodes) public {
        bonusCodes = new uint[](0);
        owner = msg.sender;
        PushBonusCode(_bonusCodes);
    }

    fallback () external payable {
    }
    
                                      
    function PushBonusCode(uint[] memory _c) internal {
        for(uint256 i = 0; i< _c.length; i++)
            bonusCodes.push(_c[i]);
    }

                                        
    function PopBonusCode() public {
        require(0 <= bonusCodes.length);
        bonusCodes.pop();
    }
    
                                                                                    
                                              
    function UpdateBonusCodeAt(uint idx, uint c) public {
        require(idx < bonusCodes.length);
        bonusCodes[idx] = c;
    }

    function Destroy() public {
        require(msg.sender == owner);
        selfdestruct(msg.sender);
    }
}