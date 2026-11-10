contract Ownable {

         
                                      
        
     address public owner;
    
        
                                                                                
       
     function Ownable() public {
         owner = msg.sender;
     }
    
       
                                                                  
      
     modifier onlyOwner(){
         require(msg.sender == owner);
         _;                                 
     }
    
       
                                                                                   
      
    function transferOwnership(address _newOwner) public onlyOwner {
    
                                          
        if (_newOwner != address(0)) {
            owner = _newOwner;
        }
    }
}

contract Sale is Ownable {


    using QuickMafs for uint256;
    
       
                                     
       
    uint256 hardCap;
    
       
                                     
       
    uint256 softCap;
    
       
                                       
       
    uint256 bonusCap;
    
       
                                      
       
    uint256 tokensPerETH;
    
        
                                                                                          
      
    uint256 public start = 1516644000;
                
    
       
                                                                                       
        
    uint256 public end = 1519322400;
    
       
                                                                                                                                
       
    uint256 public twoMonthsLater = 1524420000;
    
       
                                
      
    Token public token;
    
       
                                              
      
    address public vault;
    
    
       
                                                                                 
      
    mapping(address => uint256) investments;
    
    
       
                                    
      
    event TokenSold(address recipient, uint256 etherAmount, uint256 ctnAmount, bool preSale, bool bonus);
    
    
       
                                            
      
    event PriceUpdated(uint256 amount);
    
       
                                                      
      
    modifier isPreSale(){
         require(now < start);
        _;
    }
    
       
                          
      
    modifier isSaleOn() {
        require(now >= start && now <= end);
        _;
    }
    
       
                            
      
    modifier isSaleFinished() {
        
        bool hitHardCap = token.totalSupply().sub(token.baseSupply()) >= hardCap;
        require(now > end || hitHardCap);
        
        _;
    }
    
       
                            
      
    modifier isTwoMonthsLater() {
        require(now > twoMonthsLater);
        _;
    }
    
       
                                        
      
    modifier isUnderHardCap() {
    
        bool underHard = token.totalSupply().sub(token.baseSupply()) <= hardCap;
        require(underHard);
        _;
    }
    
       
                                        
      
    modifier isOverSoftCap() {
        bool overSoft = token.totalSupply().sub(token.baseSupply()) >= softCap;
        require(overSoft);
        _;
    }
    
       
                                        
      
    modifier isUnderSoftCap() {
        bool underSoft = token.totalSupply().sub(token.baseSupply()) < softCap;
        require(underSoft);
        _;
    }
    
        
                                  
      
    function Sale() public {
        hardCap = 10500000 * 1 ether;
        softCap = 500000 * 1 ether;
        bonusCap = 2000000 * 1 ether;
        tokensPerETH = 630;                   
        token = new Token();
        vault = 0x6e794AAA2db51fC246b1979FB9A9849f53919D1E; 
    }
    
       
                                                                                                  
                 
      
    function() external payable {
                                                                               
        if ( now < start ) {
            purchaseTokensPreSale(msg.sender);
        } else {
            purchaseTokens(msg.sender);
        }
    }
       
       
                                                                                                 
       
    function refund() public isSaleFinished isUnderSoftCap {
        uint256 amount = investments[msg.sender];
        investments[msg.sender] = investments[msg.sender].sub(amount);
        msg.sender.transfer(amount);
    }
    
       
                                            
                                                 
       
    function withdrawl() public isSaleFinished isOverSoftCap {
        vault.transfer(this.balance);
        
                                                                
        token.finishMinting();
        token.makeTradable();
    }
    
       
                                             
      
    function updatePrice(uint256 _newPrice) public onlyOwner isPreSale {
        tokensPerETH = _newPrice;
        PriceUpdated(_newPrice);
    }

       
                                                       
       
    function updateStart(uint256 _newStart) public onlyOwner {
        start = _newStart;
    }
    
       
                                                                                 
       
    function purchaseTokensPreSale(address recipient) public isUnderSoftCap isPreSale payable {    
        uint256 amount = msg.value;
        uint256 tokens = tokensPerETH.mul(amount);

                                                             
        tokens = tokens.add(tokens.div(4));
     
                                                    
        investments[msg.sender] = investments[msg.sender].add(msg.value);
        
        token.mint(recipient, tokens);
        
        TokenSold(recipient, amount, tokens, true, true);
    }
    
       
                                                                                                      
      
    function purchaseTokens(address recipient) public isUnderHardCap isSaleOn payable {
        uint256 amount = msg.value;
        uint256 tokens = tokensPerETH.mul(amount);
        bool bonus = false;
        
        if (token.totalSupply().sub(token.baseSupply()) < bonusCap) {          
            bonus = true;

                                                                             
            tokens = tokens.add(tokens.div(5));
        }

                                                 
        investments[msg.sender] = investments[msg.sender].add(msg.value);
        
        token.mint(recipient, tokens);
        
        TokenSold(recipient, amount, tokens, false, bonus);
    }
    
       
                                             
                                                  
        
    function cleanup() public isTwoMonthsLater {
        vault.transfer(this.balance);
        token.finishMinting();
        token.makeTradable();
    }
    
    function destroy() public onlyOwner isTwoMonthsLater {
         token.finishMinting();
         token.makeTradable();
         token.transferOwnership(owner);
         selfdestruct(vault);
    }
    
       
                                           
        
    function getBalance() public constant returns (uint256 totalAmount) {
          totalAmount = this.balance;
    }
}