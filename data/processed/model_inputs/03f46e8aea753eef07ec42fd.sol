contract EthDickMeasuringGamev3 {
    address owner;
    address public largestPenisOwner;
    uint256 public largestPenis;
    uint256 public withdrawDate;

    function EthDickMeasuringGamev3() public{
        owner = msg.sender;
        largestPenisOwner = 0;
        largestPenis = 0;
    }

    function () public payable{
        require(largestPenis < msg.value);
        address prevOwner = largestPenisOwner;
        uint256 prevSize = largestPenis;
        
        largestPenisOwner = msg.sender;
        largestPenis = msg.value;
        withdrawDate = 1 days;
        
                                             
                                                   
        if(prevOwner != 0x0)
            prevOwner.transfer(SafeMath.div(SafeMath.mul(prevSize, 80),100));

    }

    function withdraw() public{
        require(now >= withdrawDate);
        address roundWinner = largestPenisOwner;

                    
        largestPenis = 0;
        largestPenisOwner = 0;

                                         
                                            
        owner.transfer(SafeMath.div(SafeMath.mul(this.balance, 1),100));
        
                                            
        roundWinner.transfer(this.balance);
    }
}