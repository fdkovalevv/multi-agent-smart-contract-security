contract Crowdsale {
    address public beneficiary;
    uint public fundingGoal; 
    uint public maxGoal;
    uint public amountRaised; 
    uint public start;
    uint[4] public deadlines;                                                     
    uint[4] public prices = [909090909090909,952380952380952,970873786407766, 1000000000000000];
    token public tokenReward;
    mapping(address => uint256) public balanceOf;
    bool fundingGoalReached = false;
    event GoalReached(address beneficiary, uint amountRaised);
    event FundTransfer(address backer, uint amount, bool isContribution);
    bool crowdsaleClosed = false;

                                                                        

                                             
    function Crowdsale( ) {
        beneficiary = 0x2aA2B0Ca9405B882e02851B81706904829C4AF17;
        fundingGoal = 50000000;           
        maxGoal = 394240000;
        start = now;             
        tokenReward = token(0xCe6C866D5B28DC8bA4aA72Ad3d57A8CE2d11C4Db);
        deadlines[0]=now;
        deadlines[1]=now + 10 minutes;
        deadlines[2]=now + 20 minutes;
        deadlines[3]=now + 30 minutes;
    }

                                                                                                                    
    function () payable{
        if (crowdsaleClosed||now<start||amountRaised+amount>maxGoal) throw;
        uint amount = msg.value;
        balanceOf[msg.sender] = amount;
        amountRaised += amount;
                                                                               
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
        if (amountRaised >= fundingGoal){
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