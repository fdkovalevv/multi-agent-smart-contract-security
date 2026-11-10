contract ERC20Interface {
    function circulatingSupply() public view returns (uint);
    function balanceOf(address who) public view returns (uint);
    function transfer(address to, uint value) public returns (bool);
    event TransferEvent(address indexed from, address indexed to, uint value);
}

contract StandardToken is ERC20Interface {
    using SafeMath for uint;

    uint public maxSupply_;
    uint public circulatingSupply_;
    uint public timestampMint;
    uint public timestampRelease;
    uint8 public decimals;

    string public symbol;
    string public  name;

    address public owner;

    mapping(address => uint) public balances;
    mapping (address => uint) public permissonedAccounts;

       
                                                 
      
    modifier onlyAfter() {
        require(now >= timestampMint + 3 weeks);
        _;
    }

       
                                            
      
    modifier hasPermission(uint _level) {
        require(permissonedAccounts[msg.sender] > 0);
        require(permissonedAccounts[msg.sender] <= _level);
        _;
    }

       
                                              
      
    function circulatingSupply() public view returns (uint) {
        return circulatingSupply_;
    }

       
                                  
                                                            
                                                                          
      
    function balanceOf(address _owner) public view returns (uint balance) {
        return balances[_owner];
    }

       
                                                    
                               
                                            
      
    function transfer(address _to, uint _value) public returns (bool) {
        require(_to != address(0));
        require(_value <= balances[msg.sender]);
        balances[msg.sender] = balances[msg.sender].sub(_value);
        balances[_to] = balances[_to].add(_value);
        TransferEvent(msg.sender, _to, _value);
        return true;
    }
}

contract Who is StandardToken {

    mapping (address => uint) public votings_;
    mapping (address => uint8) public icoAccounts;
    address public prizePool;
    uint public icoPool;
    uint public raisedIcoValue;
    uint public maxMint;


    event WinningEvent(address[] winner, address contest, uint payoutValue);
    event VotingStarted(address _voting, uint _duration, uint _costPerVote);
    event ParticipatedInVoting(address _sender, address _votingContract, bytes32 _hash, uint _voteAmount);

    modifier icoPhase() {
        require(now >= timestampRelease);
        require(now <= 32 days + timestampRelease);
        require(msg.value >= 2*(10**16));
        _;

    }

    function Who() public {
        owner = 0x4c556b28A7D62D3b7A84481521308fbb9687f38F;

        name = "WhoHas";
        symbol = "WHO";
        decimals = 18;

        permissonedAccounts[owner] = 1;
        timestampRelease = now + 4 hours + 2 days;

        balances[0x4c556b28A7D62D3b7A84481521308fbb9687f38F] = 150000000*(10**18);                
        icoPool = 100000000*(10**18);                
        maxSupply_ = 1500000000*(10**18);              
        maxMint = 150000*(10**18);        
        circulatingSupply_ = circulatingSupply_.add(balances[msg.sender]).add(icoPool);              
    }

       
                                         
                                                                          
      
    function icoBuy() public icoPhase() payable {
        prizePool.transfer(msg.value);
        raisedIcoValue = raisedIcoValue.add(msg.value);
        uint256 tokenAmount = calculateTokenAmountICO(msg.value);

        require(icoPool >= tokenAmount);

        icoPool = icoPool.sub(tokenAmount);
        balances[msg.sender] += tokenAmount;
        TransferEvent(prizePool, msg.sender, tokenAmount);
    }

       
                                            
                                                                           
      
    function calculateTokenAmountICO(uint256 _etherAmount) public icoPhase constant returns(uint256) {
                                                            
                                                        
        if (now <= 10 days + timestampRelease) {
            require(icoAccounts[msg.sender] == 1);
            return _etherAmount.mul(4420);
        } else {
            require(icoAccounts[msg.sender] == 2);
            return _etherAmount.mul(3315);
        }
    }

       
                                            
                                                                     
                                                                              
      
    function updatePermissions(address _account, uint _level) public hasPermission(1) {
        require(_level != 1 && msg.sender != _account);
        permissonedAccounts[_account] = _level;
    }

       
                                                                    
                                                   
      
    function updatePrizePool(address _account) public hasPermission(1) {
        prizePool = _account;
    }

       
                                                                                                                     
                                                                           
      
    function mint(uint _mintAmount) public onlyAfter hasPermission(2) {
        require(_mintAmount <= maxMint);
        require(circulatingSupply_ + _mintAmount <= maxSupply_);
        balances[owner] = balances[owner].add(_mintAmount);
        circulatingSupply_ = circulatingSupply_.add(_mintAmount);
        timestampMint = now;
    }

    function registerForICO(address[] _icoAddresses, uint8 _level) public hasPermission(3) {
        for (uint i = 0; i < _icoAddresses.length; i++) {
            icoAccounts[_icoAddresses[i]] = _level;
        }
    }

       
                                                    
                                                           
                                                     
      
    function gernerateVoting(uint _timespan, uint _votePrice) public hasPermission(3) {
        require(_votePrice > 0 && _timespan > 0);
        address generatedVoting = new WhoVote(this, _timespan);
        votings_[generatedVoting] = _votePrice;
        VotingStarted(generatedVoting, _timespan, _votePrice);
    }

       
                                                    
                                                     
                                                     
      
    function addVoting(address _votingContract, uint _votePrice) public hasPermission(3) {
        votings_[_votingContract] = _votePrice;
    }

       
                         
                                                      
      
    function finalizeVoting(address _votingContract) public hasPermission(3) {
        votings_[_votingContract] = 0;
    }

       
                                     
                                                            
                                                                    
                                                          
      
    function payout(address[] _winner, uint _payoutValue, address _votingAddress) public hasPermission(3) {
        for (uint i = 0; i < _winner.length; i++) {
            transfer(_winner[i], _payoutValue);
        }
        WinningEvent(_winner, _votingAddress, _payoutValue);
    }

       
                                    
                                                      
                                             
                                        
      
    function payForVote(address _votingContract, bytes32 _hash, uint _quantity) public {
        require(_quantity >= 1 && _quantity <= 5);
        uint votePrice = votings_[_votingContract];
        require(votePrice > 0);
        transfer(prizePool, _quantity.mul(votePrice));
        sendVote(_votingContract, msg.sender, _hash);
        ParticipatedInVoting(msg.sender, _votingContract, _hash, _quantity);
    }

       
                                                  
                                                 
                                    
                                             
      
    function sendVote(address _contract, address _sender, bytes32 _hash) private returns (bool) {
        return WhoVote(_contract).recieveVote(_sender, _hash);
    }

}