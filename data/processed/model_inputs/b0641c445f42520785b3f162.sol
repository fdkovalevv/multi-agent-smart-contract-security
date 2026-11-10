contract ERC20Interface {

                                 
    function totalSupply() public constant returns (uint256 supply);

                                                                     
    function balanceOf(address _owner) public constant returns (uint256 balance);

                                                  
    function transfer(address _to, uint256 _value) public returns (bool success);

                                                                     
    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success);

                                                                                             
                                                                                        
                                                           
    function approve(address _spender, uint256 _value) public returns (bool success);

                                                                                 
    function allowance(address _owner, address _spender) public constant returns (uint256 remaining);

                                             
    event Transfer(address indexed _from, address indexed _to, uint256 _value);

                                                                              
    event Approval(address indexed _owner, address indexed _spender, uint256 _value);
}

contract ERC20Token is ERC20Interface{

                                                                                     
    string public constant symbol = "TBA";

                                                   
    string public constant name = "TBA";

                                                                        
    uint8 public constant decimals = 6;

                                              
    uint256 public constant unit = 1000000;

                                
    mapping(address => uint256) balances;

                                                                          
    mapping(address => mapping (address => uint256)) allowed;

                                                   
    function balanceOf(address _owner) public constant returns (uint256) {
        return balances[_owner];
    }

                                                                   
    function transfer(address _to, uint256 _amount) public returns (bool) {
        if (balances[msg.sender] >= _amount && _amount > 0
                && balances[_to] + _amount > balances[_to]) {
            balances[msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(msg.sender, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

                                                                     
                                                                                          
                                                                                             
                                                                                   
                                                                                       
                                            
    function transferFrom(
        address _from,
        address _to,
        uint256 _amount
    ) public returns (bool) {
        if (balances[_from] >= _amount
            && allowed[_from][msg.sender] >= _amount && _amount > 0
                && balances[_to] + _amount > balances[_to]) {
            balances[_from] -= _amount;
            allowed[_from][msg.sender] -= _amount;
            balances[_to] += _amount;
            Transfer(_from, _to, _amount);
            return true;
        } else {
            return false;
        }
    }

                                                                                             
                                                                                        
    function approve(address _spender, uint256 _amount) public returns (bool) {
        allowed[msg.sender][_spender] = _amount;
        Approval(msg.sender, _spender, _amount);
        return true;
    }

                                                                                      
    function allowance(address _owner, address _spender) public constant returns (uint256) {
        return allowed[_owner][_spender];
    }

}

contract LittleSisterToken is ERC20Token{

                                                            
                                                        
    uint8 public vig;

                                                               
                                                                              
    uint256 public maxSupply;

                                                                    
    uint256 totalSupply_;

                                                                                   
                                                                                                   
               
    uint public validityDate;

                                                  
    uint public maxBuyingDate;

                                                  
    address public sister;

                                               
    address public owner;

                             
    address public vigAddress;

                                                                               
    bool public lost;

                                                                               
                                                          
    function LittleSisterToken() {
        owner = msg.sender;
        vigAddress = msg.sender;
        totalSupply_ = 0;
        lost = false;
    }

                                                                                  
                                                       
    function () payable {
        if (msg.sender != sister){
            buy();
        }
    }

                              
    function setVigAddress(address _newVigAddress) public {
        require(msg.sender == owner);
        vigAddress = _newVigAddress;
    }

                                        
    function totalSupply() public constant returns (uint256) {
        return totalSupply_;
    }

                                                                   
                                             
                                                            
    function registerSister(address _sister) public returns (bool) {
        BigSisterToken sisterContract;

                                                                            
                                       
        require(sister == address(0));
                                                                                            
        require(_sister != address(this));

                                                            
        sisterContract = BigSisterToken(_sister);
        require(sisterContract.owner() == owner);
        require(sisterContract.sister() == address(this));

                                                                   
        sister = _sister;

                                                                                              
        maxSupply = sisterContract.maxSupply();
        vig = sisterContract.vig();
        validityDate = sisterContract.validityDate();
        maxBuyingDate = sisterContract.maxBuyingDate();

        return true;
    }

                                                             
                                    
    function sellPrice() public constant returns (uint256){
        BigSisterToken sisterContract = BigSisterToken(sister);
        return sisterContract.sellPrice();
    }

                                                        
    function buyPrice() public constant returns (uint256){
        BigSisterToken sisterContract = BigSisterToken(sister);
        return sisterContract.buyPrice();
    }

                                                                        
    function sendFunds() public returns(bool){
        require(msg.sender == sister);
        require(msg.sender.send(this.balance));
                                                             
        lost = true;
        return true;
    }

                                                  
                                                                                                 
    function releaseContract() public {
        require(now > validityDate);
        require(msg.sender == sister);
        selfdestruct(owner);
    }

                                                               
                                                                        
    function winningValue() public constant returns (uint256 value){
        LittleSisterToken sisterContract = LittleSisterToken(sister);

        if (totalSupply_ > 0){
            value = (this.balance + sisterContract.balance) / totalSupply_;
        }

        return value;
    }

                                      
    function availableSupply() public constant returns (uint256 supply){
        LittleSisterToken sisterContract;
        uint256 sisterSupply;

        if ((buyPrice()) == 0 || (now > maxBuyingDate)){
                                                                 
            return 0;
        } else {

            sisterContract = LittleSisterToken(sister);
            sisterSupply = sisterContract.totalSupply();
                                                            
            assert(maxSupply >= totalSupply_ + sisterSupply);
            supply = maxSupply - totalSupply_ - sisterSupply;
            return supply;
        }
    }

                                                                             
    function buy() public payable returns (uint amount){
        uint256 house;
        uint256 supply;
        uint256 price;

                                             
        require(now <= maxBuyingDate);
                        
        price = buyPrice();
                                                         
                                                                 
        require(price > 0);
        house = msg.value / vig;
                                         
        require(house > 0);
        amount = msg.value / price;
        supply = availableSupply();
        require(amount <= supply);
                                                                 
        vigAddress.transfer(house);
        totalSupply_ += amount;
                                                                  
        balances[msg.sender] += amount;
        Transfer(this, msg.sender, amount);
        return amount;
    }

                                                                             
                                                                               
                                                                                       
    function sell(uint _amount) public returns (uint256 revenue){
                                                                               
                                                                                    
                                                                                
        require(sellPrice() > 0);
        require(!lost);
                                                            
        require(balances[msg.sender] >= _amount);
        revenue = _amount * sellPrice();
        require(this.balance >= revenue);
                                        
        balances[msg.sender] -= _amount;
        totalSupply_ -= _amount;
                                                                                        
        msg.sender.transfer(revenue);
        Transfer(msg.sender, this, _amount);
        return revenue;
    }

                                 
    function sellAll() public returns (uint256){
        uint256 amount = balances[msg.sender];
        return sell(amount);
    }

}

contract PriceIncreasingLittleSisterToken is LittleSisterToken{

                                                                                  
                                                       
    function () payable {
        if (msg.sender != sister){
            buy();
        }
    }

                                                            
                                                                         
    function buy() public payable returns (uint amount){
        PriceIncreasingToken sisterContract = PriceIncreasingToken(sister);

                     
        amount = super.buy();
                                                                          
        sisterContract.sisterCheckPrice(amount);
        return amount;
    }

}

contract TrumpFullTermToken is PriceIncreasingLittleSisterToken{

    string public constant symbol = "TFT";

    string public constant name = "Trump Full Term Token";

}