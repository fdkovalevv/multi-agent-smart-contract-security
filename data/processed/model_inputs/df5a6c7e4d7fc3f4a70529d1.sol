contract Crowdsale {
                                                                      
    address public beneficiary = 0x003230bbe64eccd66f62913679c8966cf9f41166; 
                                                                                
    uint public fundingGoal = 50000000;
                                                 
    uint public maxGoal = 394240000; 
                                                       
    uint public amountRaised; 
                                         
    uint public start = 1487257200; 
                                           
    uint public tokensSold; 
                                                                
    uint[4] public deadlines = [1487260800, 1487865600, 1488470400,1489075200];
    uint[4] public prices = [833333333333333, 909090909090909,952380952380952, 1000000000000000];
                                           
    token public tokenReward;
                                                
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    bool crowdsaleClosed = false;
                                                             
    event GoalReached(address beneficiary, uint amountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);
    

                                                
    function Crowdsale( ) {
        tokenReward = token(0xc378b7e2f88f945be121d80edcbc31bc7259a983);
    }

                                                                                                                                           
                                                            
    function () payable{
        uint amount = msg.value;
        uint numTokens = amount / getPrice();
        if (crowdsaleClosed||now<start||tokensSold+numTokens>maxGoal) throw;
        balanceOf[msg.sender] = amount;
        amountRaised += amount;
        tokensSold+=numTokens;
        if(!tokenReward.transferFrom(beneficiary, msg.sender, numTokens)) throw;
        FundTransfer(msg.sender, amount, true);
    }
    
                                          
    function getPrice() constant returns (uint256 price){
        for(var i = 0; i < deadlines.length; i++)
            if(now<deadlines[i])
                return prices[i];
        return prices[prices.length-1];                                                             
    }

    modifier afterDeadline() { if (now >= deadlines[deadlines.length-1]) _; }

                                                                                 
    function checkGoalReached() afterDeadline {
        if (tokensSold >= fundingGoal){
            fundingGoalReached = true;
            GoalReached(beneficiary, amountRaised);
        }
        crowdsaleClosed = true;
    }

                                                                           
    function safeWithdrawal() afterDeadline {
                                                                              
        if (!fundingGoalReached) {
            uint amount = balanceOf[msg.sender];
            balanceOf[msg.sender] = 0;
            if (amount > 0) {
                if (msg.sender.send(amount)) {
                    FundTransfer(msg.sender, amount, false);
                } else {
                    balanceOf[msg.sender] = amount;
                }
            }
        }
                                                                                                            
        if (fundingGoalReached && beneficiary == msg.sender) {
            if (beneficiary.send(amountRaised)) {
                FundTransfer(beneficiary, amountRaised, false);
            } else {
                                                                                     
                fundingGoalReached = false;
            }
        }
    }
}