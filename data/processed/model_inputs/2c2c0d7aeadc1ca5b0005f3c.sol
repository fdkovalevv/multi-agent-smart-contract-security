contract Owned {
    address public owner;

    function Owned() {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner {
        owner = newOwner;
    }
}

contract ICOEvent is Owned {

    ESGToken public token;                                                                                

    uint256 public startTime = 0;                                           
    uint256 public endTime;                                                            
    uint256 duration;                                                              
    bool parametersSet;                                                                                       
    bool supplySet;                                                               

    address holdingAccount = 0x0;                                                               
    uint256 public totalTokensMinted;                                                             

                            
    uint256 public rate_toTarget;                                                                                 
    uint256 public rate_toCap;                                                                             
    uint256 public totalWeiContributed = 0;                                                     
    uint256 public minWeiContribution = 0.01 ether;                                                            
    uint256 constant weiEtherConversion = 10**18;                                                         

                     
    uint256 public baseTargetInWei;                                                       
    uint256 public icoCapInWei;                                                     

    event logPurchase (address indexed purchaser, uint value, uint256 tokens);

    enum State { Active, Refunding, Closed }                                              
    State public state;
    mapping (address => uint256) public deposited;                                            
    mapping (address => uint256) public tokensIssued;                                       

                                                                                                

                       

                                                                                              
                                               

                                                                                               
    function ICOEvent() {
        state = State.Active;
        totalTokensMinted = 0;
        parametersSet = false;
        supplySet = false;
    }

                                                                                                

                                                                              

                                                                                    
                                                                                                   
                                                     
                                                                                                   
                                                               
                                                                                                  
                                          
                                                                                             
                                                                                  
                                                   
                                                                                                
    function ICO_setParameters(address _tokenAddress, uint256 _target_rate, uint256 _cap_rate, uint256 _baseTarget, uint256 _cap, address _holdingAccount, uint256 _duration) onlyOwner {
        require(_target_rate > 0 && _cap_rate > 0);
        require(_baseTarget >= 0);
        require(_cap > 0);
        require(_duration > 0);
        require(_holdingAccount != 0x0);
        require(_tokenAddress != 0x0);

        rate_toTarget = _target_rate;
        rate_toCap = _cap_rate;
        token = ESGToken(_tokenAddress);
        baseTargetInWei = SafeMath.safeMul(_baseTarget, weiEtherConversion);
        icoCapInWei = SafeMath.safeMul(_cap, weiEtherConversion);
        holdingAccount = _holdingAccount;
        duration = SafeMath.safeMul(_duration, 1 days);
        parametersSet = true;
    }

                                                                                                

                                                                              

                                                                                               
    function eventConfigured() internal constant returns (bool) {
        return parametersSet && supplySet;
    }

                                                                                                

                                                                                  

                                                                                                
    function ICO_start() onlyOwner {
        assert (eventConfigured());
        startTime = now;
        endTime = SafeMath.safeAdd(startTime, duration);
    }

    function ICO_start_future(uint _startTime) onlyOwner {
        assert(eventConfigured());
        require(_startTime > now);
        startTime = _startTime;
        endTime = SafeMath.safeAdd(startTime, duration);
    }

    function ICO_token_supplyCap() onlyOwner {
        require(token.parametersAreSet());                                                                   

                                                                       
        uint256 targetTokens = SafeMath.safeMul(baseTargetInWei, rate_toTarget);         
        targetTokens = SafeMath.safeDiv(targetTokens, weiEtherConversion);

                                                                                    
        uint256 capTokens = SafeMath.safeSub(icoCapInWei, baseTargetInWei);
        capTokens = SafeMath.safeMul(capTokens, rate_toCap);
        capTokens = SafeMath.safeDiv(capTokens, weiEtherConversion);

          
                                                                                            
                                                                                
                                                                           
          
        uint256 mmentTokens = SafeMath.safeMul(targetTokens, 10);
        mmentTokens = SafeMath.safeDiv(mmentTokens, 100);

                                                                             
        uint256 tokens_available = SafeMath.safeAdd(capTokens, targetTokens); 

        uint256 total_Token_Supply = SafeMath.safeAdd(tokens_available, mmentTokens);                   

        token.setTokenCapInUnits(total_Token_Supply);                                                
        token.mintLockedTokens(mmentTokens);                                                 
        supplySet = true;
    }

                                                                                                

                                                                               

                                                                  

                                                                                               
    function () payable {
        deposit(msg.sender);
    }

                                                                                                

                                                                                            

                                                                                              
                                           

                                           
                                                                                                
                                                                                

                                       
                                                                      

                                                    
            
                                                                                               
    function deposit(address _for) payable {

           
                                                                                               
          
        require(validPurchase(msg.value));                                                                          
        require(state == State.Active);                                  
        require(!ICO_Ended());                                                  

           
                                                                                           
                                                                    
          
        uint256 targetContribution = getPreTargetContribution(msg.value);                                                 
        uint256 capContribution = SafeMath.safeSub(msg.value, targetContribution);                                       
        totalWeiContributed = SafeMath.safeAdd(totalWeiContributed, msg.value);                                     

           
                                                                         
                                                                                  
          
        uint256 targetTokensToMint = SafeMath.safeMul(targetContribution, rate_toTarget);                          
        uint256 capTokensToMint = SafeMath.safeMul(capContribution, rate_toCap);                                   
        uint256 tokensToMint = SafeMath.safeAdd(targetTokensToMint, capTokensToMint);                      
        
        tokensToMint = SafeMath.safeDiv(tokensToMint, weiEtherConversion);                                        
        totalTokensMinted = SafeMath.safeAdd(totalTokensMinted, tokensToMint);                                           

        deposited[_for] = SafeMath.safeAdd(deposited[_for], msg.value);                                                      
        tokensIssued[_for] = SafeMath.safeAdd(tokensIssued[_for], tokensToMint);                                

        token.mint(_for, tokensToMint);                                                                                   
        logPurchase(_for, msg.value, tokensToMint);
    }

                                                                                                

                                                                                                    
                                                             

                                                                                

                                                                       
            
                                                                                               
    function getPreTargetContribution(uint256 _valueSent) internal returns (uint256) {
        
        uint256 targetContribution = 0;                                                                      

        if (totalWeiContributed < baseTargetInWei) {                                             
            if (SafeMath.safeAdd(totalWeiContributed, _valueSent) > baseTargetInWei) {                                               
                targetContribution = SafeMath.safeSub(baseTargetInWei, totalWeiContributed);                              
            } else {
                targetContribution = _valueSent;
            }
        }
        return targetContribution;    
    }

                                                                                                

                                                            

                                                                                               

                                               
    function ICO_Live() public constant returns (bool) {
        return (now >= startTime && now < endTime && state == State.Active);
    }

                                                                   
    function validPurchase(uint256 _value) payable returns (bool) {                       
        bool validTime = (now >= startTime && now < endTime);                              
        bool validAmount = (_value >= minWeiContribution);
        bool withinCap = SafeMath.safeAdd(totalWeiContributed, _value) <= icoCapInWei;

        return validTime && validAmount && withinCap;
    }

                    
    function ICO_Ended() public constant returns (bool) {
        bool capReached = (totalWeiContributed >= icoCapInWei);
        bool stateValid = state == State.Closed;

        return (now >= endTime) || capReached || stateValid;
    }

                                        
    function Wei_Remaining_To_ICO_Cap() public constant returns (uint256) {
        return (icoCapInWei - totalWeiContributed);
    }

                                                    
    function baseTargetReached() public constant returns (bool) {
    
        return totalWeiContributed >= baseTargetInWei;
    }

                                        
    function capReached() public constant returns (bool) {
    
        return totalWeiContributed == icoCapInWei;
    }

                                                                                                

                                                                                                
                              

                                                                                                 

                                                                                                                     
                                                                                                             
                                                                                               

    event Closed();

                                                             
    function close() onlyOwner {
        require((now >= endTime) || (totalWeiContributed >= icoCapInWei));
        require(state==State.Active);
        state = State.Closed;
        Closed();

        holdingAccount.transfer(this.balance);
    }
}