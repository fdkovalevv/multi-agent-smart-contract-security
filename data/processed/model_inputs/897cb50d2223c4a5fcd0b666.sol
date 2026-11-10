contract Ownable {
    address public owner;


       
                                                                                           
               
       
    function Ownable() {
        owner = msg.sender;
    }


       
                                                                 
       
    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }


       
                                                                                       
                                                            
       
    function transferOwnership(address newOwner) onlyOwner {
        if (newOwner != address(0)) {
            owner = newOwner;
        }
    }

}

contract Authorizable {

    address[] authorizers;
    mapping(address => uint) authorizerIndex;

       
                                                                  
       
    modifier onlyAuthorized {
        require(isAuthorized(msg.sender));
        _;
    }

       
                                                      
       
    function Authorizable() {
        authorizers.length = 2;
        authorizers[1] = msg.sender;
        authorizerIndex[msg.sender] = 1;
    }

       
                                                 
                                                                      
                                             
       
    function getAuthorizer(uint authorizerIndex) external constant returns(address) {
        return address(authorizers[authorizerIndex + 1]);
    }

       
                                                         
                                                             
                                                     
       
    function isAuthorized(address _addr) constant returns(bool) {
        return authorizerIndex[_addr] > 0;
    }

       
                                            
                                                           
       
    function addAuthorized(address _addr) external onlyAuthorized {
        authorizerIndex[_addr] = authorizers.length;
        authorizers.length++;
        authorizers[authorizers.length - 1] = _addr;
    }

}

contract TopCoinDistribution is Ownable, Authorizable {
    using SafeMath for uint;
    event TokenSold(address recipient, uint ether_amount, uint pay_amount, uint exchangerate);
    event AuthorizedCreate(address recipient, uint pay_amount);
    event TopCoinSaleClosed();

    TopCoin public token = new TopCoin();

    address public multisigVault;

    uint public hardcap = 87500 ether;

    uint public rate = 3600*(10 ** 6);                     

    uint totalToken = 2100000000 * (10 ** 6);      

    uint public authorizeMintToken = 210000000 * (10 ** 6);      

    uint public altDeposits = 0;        

    uint public start = 1504008000;                                                           

    address partenersAddress = 0x6F3c01E350509b98665bCcF7c7D88C120C1762ef;                   
    address operationAddress = 0xb5B802F753bEe90C969aD27a94Da5C179Eaa3334;                   
    address technicalAddress = 0x62C1eC256B7bb10AA53FD4208454E1BFD533b7f0;                   

       
                                                                     
       
    modifier saleIsOn() {
        require(now > start && now < start + 28 days);
        _;
    }

       
                                                                                       
       
    modifier isUnderHardCap() {
        require(multisigVault.balance + msg.value + altDeposits <= hardcap);
        _;
    }

    function isContract(address _addr) constant internal returns(bool) {
        uint size;
        if (_addr == 0) return false;
        assembly {
        size := extcodesize(_addr)
        }
        return size > 0;
    }

       
                                                               
                                                        
       
    function createTokens(address recipient) public isUnderHardCap saleIsOn payable {
        require(!isContract(recipient));
        uint tokens = rate.mul(msg.value).div(1 ether);
        token.mint(recipient, tokens);
        require(multisigVault.send(msg.value));
        TokenSold(recipient, msg.value, tokens, rate);
    }

       
                                                  
                                                             
       
    function setAuthorizeMintToken(uint _authorizeMintToken) public onlyOwner {
        authorizeMintToken = _authorizeMintToken;
    }

       
                                                                                                                
                                                          
       
    function setAltDeposit(uint totalAltDeposits) public onlyOwner {
        altDeposits = totalAltDeposits;
    }

       
                              
                                
       
    function setRate(uint _rate) public onlyOwner {
        rate = _rate;
    }


       
                                                                                                  
                                                        
                                                     
       
    function authorizedCreateTokens(address recipient, uint _tokens) public onlyAuthorized {
        uint tokens = _tokens * (10 ** 6);
        uint totalSupply = token.totalSupply();
        require(totalSupply + tokens <= authorizeMintToken);
        token.mint(recipient, tokens);
        AuthorizedCreate(recipient, tokens);
    }

       
                                                
                                      
       
    function setHardCap(uint _hardcap) public onlyOwner {
        hardcap = _hardcap;
    }

       
                                                      
                                   
       
    function setStart(uint _start) public onlyOwner {
        start = _start;
    }

       
                                                          
                                                          
       
    function setMultisigVault(address _multisigVault) public onlyOwner {
        if (_multisigVault != address(0)) {
            multisigVault = _multisigVault;
        }
    }

       
                                                                        
                                                    
                                                                 
                     
       
    function finishMinting() public onlyOwner {
        uint issuedTokenSupply = token.totalSupply();
        uint partenersTokens = totalToken.mul(20).div(100);
        uint technicalTokens = totalToken.mul(30).div(100);
        uint operationTokens = totalToken.mul(20).div(100);

        token.mint(partenersAddress, partenersTokens);
        token.mint(technicalAddress, technicalTokens);
        token.mint(operationAddress, operationTokens);

        uint restrictedTokens = totalToken.sub(issuedTokenSupply).sub(partenersTokens).sub(technicalTokens).sub(operationTokens);
        token.mint(multisigVault, restrictedTokens);
        token.finishMinting();
        token.transferOwnership(owner);
        TopCoinSaleClosed();
    }

       
                                                                            
                                                               
       
    function retrieveTokens(address _token) public onlyOwner {
        ERC20 token = ERC20(_token);
        token.transfer(multisigVault, token.balanceOf(this));
    }

       
                                                                                                       
                  
       
    function() external payable {
        createTokens(msg.sender);
    }

}