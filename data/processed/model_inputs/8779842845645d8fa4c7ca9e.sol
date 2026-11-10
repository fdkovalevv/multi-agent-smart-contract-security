contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


     
                                                                                         
             
     
  function Ownable() public {
    owner = msg.sender;
  }

     
                                                               
     
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }

     
                                                                                     
                                                          
     
  function transferOwnership(address newOwner) public onlyOwner {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

contract HasNoContracts is Ownable {

     
                                                
                                                                    
     
  function reclaimContract(address contractAddr) external onlyOwner {
    Ownable contractInst = Ownable(contractAddr);
    contractInst.transferOwnership(owner);
  }
}

contract CanReclaimToken is Ownable {
  using SafeERC20 for ERC20Basic;

     
                                                  
                                                              
     
  function reclaimToken(ERC20Basic token) external onlyOwner {
    uint256 balance = token.balanceOf(this);
    token.safeTransfer(owner, balance);
  }

}

contract Destructible is Ownable {

  function Destructible() public payable { }

     
                                                                                 
     
  function destroy() onlyOwner public {
    selfdestruct(owner);
  }

  function destroyAndSend(address _recipient) onlyOwner public {
    selfdestruct(_recipient);
  }
}

contract DOCTCrowdsale is Ownable, HasNoContracts, CanReclaimToken, Destructible {
    using SafeMath for uint256;

    uint256 constant  DOCT_TO_ETH_DECIMALS = 10000000000;                                                                     

    DOCTToken public token;

    struct Round {
        uint256 start;                                              
        uint256 end;                                              
        uint256 rate;                                                                         
        uint256 rateBulk;                                
        uint256 bulkThreshold;                                                        
    }
    Round[] public rounds;                                     
    uint256 public hardCap;                                       
    uint256 public tokensMinted;                                     
    bool public finalized;                                  

    function DOCTCrowdsale (
        uint256 _hardCap,
        uint256[] roundStarts,
        uint256[] roundEnds,
        uint256[] roundRates,
        uint256[] roundRatesBulk,
        uint256[] roundBulkThreshold
    ) public {
        token = new DOCTToken();
        token.setFounder(owner);
        token.setTransferEnabled(false);

        tokensMinted = token.totalSupply();

                                                            
        require(_hardCap > 0);                                            
        hardCap = _hardCap;

        initRounds(roundStarts, roundEnds, roundRates, roundRatesBulk, roundBulkThreshold);
    }
    function initRounds(uint256[] roundStarts, uint256[] roundEnds, uint256[] roundRates, uint256[] roundRatesBulk, uint256[] roundBulkThreshold) internal {
        require(
            (roundStarts.length > 0)  &&                                                    
            (roundStarts.length == roundEnds.length) &&
            (roundStarts.length == roundRates.length) &&
            (roundStarts.length == roundRatesBulk.length) &&
            (roundStarts.length == roundBulkThreshold.length)
        );                   
        uint256 prevRoundEnd = now;
        rounds.length = roundStarts.length;                                      
        for(uint8 i=0; i < roundStarts.length; i++){
            rounds[i] = Round({start:roundStarts[i], end:roundEnds[i], rate:roundRates[i], rateBulk:roundRatesBulk[i], bulkThreshold:roundBulkThreshold[i]});
            Round storage r = rounds[i];
            require(prevRoundEnd <= r.start);
            require(r.start < r.end);
            require(r.bulkThreshold > 0);
            prevRoundEnd = rounds[i].end;
        }
    }
    function setRound(uint8 roundNum, uint256 start, uint256 end, uint256 rate, uint256 rateBulk, uint256 bulkThreshold) onlyOwner external {
        uint8 round = roundNum-1;
        if(round > 0){
            require(rounds[round - 1].end <= start);
        }
        if(round < rounds.length - 1){
            require(end <= rounds[round + 1].start);   
        }
        rounds[round].start = start;
        rounds[round].end = end;
        rounds[round].rate = rate;
        rounds[round].rateBulk = rateBulk;
        rounds[round].bulkThreshold = bulkThreshold;
    }


       
                        
      
    function() payable public {
        require(msg.value > 0);
        require(crowdsaleRunning());

        uint256 rate = currentRate(msg.value);
        require(rate > 0);
        uint256 tokens = rate.mul(msg.value).div(DOCT_TO_ETH_DECIMALS);
        mintTokens(msg.sender, tokens);
    }

       
                                                                 
                                            
                                           
                                                                                                      
      
    function saleNonEther(address beneficiary, uint256 amount, string            ) onlyOwner external{
        mintTokens(beneficiary, amount);
    }

       
                                                  
                                                    
                                                  
                                                                                                      
      
    function bulkTokenSend(address[] beneficiaries, uint256[] amounts, string            ) onlyOwner external{
        require(beneficiaries.length == amounts.length);
        for(uint32 i=0; i < beneficiaries.length; i++){
            mintTokens(beneficiaries[i], amounts[i]);
        }
    }
       
                                             
                                                    
                                           
                                                                                                      
      
    function bulkTokenSend(address[] beneficiaries, uint256 amount, string            ) onlyOwner external{
        require(amount > 0);
        for(uint32 i=0; i < beneficiaries.length; i++){
            mintTokens(beneficiaries[i], amount);
        }
    }

       
                                           
       
    function crowdsaleRunning() constant public returns(bool){
        return !finalized && (tokensMinted < hardCap) && (currentRoundNum() > 0);
    }

       
                                          
                                                                   
      
    function currentRoundNum() view public returns(uint8) {
        for(uint8 i=0; i < rounds.length; i++){
            if( (now > rounds[i].start) && (now <= rounds[i].end) ) return i+1;
        }
        return 0;
    }
       
                                                                      
                                              
                                                                         
      
    function currentRate(uint256 amount) view public returns(uint256) {
        uint8 roundNum = currentRoundNum();
        if(roundNum == 0) {
            return 0;
        }else{
            uint8 round = roundNum-1;
            if(amount < rounds[round].bulkThreshold){
                return rounds[round].rate;
            }else{
                return rounds[round].rateBulk;
            }
        }
    }

       
                                                                           
      
    function mintTokens(address beneficiary, uint256 amount) internal {
        tokensMinted = tokensMinted.add(amount);
        require(tokensMinted <= hardCap);
        assert(token.mint(beneficiary, amount));
    }

       
                                            
      
    function claimEther() public onlyOwner {
        if(this.balance > 0){
            owner.transfer(this.balance);
        }
    }

       
                                                                                       
      
    function finalizeCrowdsale() onlyOwner public {
        finalized = true;
        assert(token.finishMinting());
        token.setTransferEnabled(true);
        token.transferOwnership(owner);
        claimEther();
    }

}