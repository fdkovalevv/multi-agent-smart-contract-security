contract owned {
    address public owner;
 
    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

contract CandySale is owned {
    
    address public teamWallet = address(0x7Bd19c5Fa45c5631Aa7EFE2Bf8Aa6c220272694F);

    uint public fundingGoal;
    uint public amountRaised;
                   
    uint public beginTime = now;
    uint public stage2BeginTime = 1517529600;                
    uint public stage3BeginTime = 1518393600;                
    uint public stage4BeginTime = 1519257600;                 
    uint public endTime = 1519776000;                        

    CandyCoin public tokenReward;

    event FundTransfer(address backer, uint amount, bool isContribution);

       
                          
      
                      
       
    function CandySale(
        CandyCoin addressOfTokenUsedAsReward
    ) {
        tokenReward = addressOfTokenUsedAsReward;
    }
    
                                    
    function withdrawTokens() onlyOwner {
        tokenReward.transfer(msg.sender, tokenReward.balanceOf(this));
        FundTransfer(msg.sender, tokenReward.balanceOf(this), false);
    }

    function currentPrice() constant returns (uint) {
        if ( now <= stage2BeginTime ) return 100 szabo;
        if ( now > stage2BeginTime && now <= stage3BeginTime) return 500 szabo;
        if ( now > stage3BeginTime && now <= stage4BeginTime) return 1000 szabo;
        if ( now > stage4BeginTime ) return 1500 szabo;
    }
    
                                        
    function buyTokens(address beneficiary) payable {
        require(msg.value > 0);
        uint amount = msg.value;
        amountRaised += amount;
        tokenReward.transfer(beneficiary, amount*1000000000000000000/currentPrice());
        FundTransfer(beneficiary, amount, true);
        teamWallet.transfer(msg.value);

    }

       
                        
      
                                                                                                                 
       
    function () payable onlyCrowdsalePeriod {
        buyTokens(msg.sender);
    }

    modifier onlyCrowdsalePeriod() { 
        require ( now >= beginTime && now <= endTime ) ;
        _; 
    }

    

}