contract ERC20 {
  uint public totalSupply;
  function balanceOf(address who) constant returns (uint);
  function allowance(address owner, address spender) constant returns (uint);

  function transfer(address to, uint value) returns (bool ok);
  function transferFrom(address from, address to, uint value) returns (bool ok);
  function approve(address spender, uint value) returns (bool ok);
  event Transfer(address indexed from, address indexed to, uint value);
  event Approval(address indexed owner, address indexed spender, uint value);
}

contract SafeMath {
    function add(uint256 x, uint256 y) constant internal returns (uint256 z) {
        assert((z = x + y) >= x);
    }

    function sub(uint256 x, uint256 y) constant internal returns (uint256 z) {
        assert((z = x - y) <= x);
    }

    function mul(uint256 x, uint256 y) constant internal returns (uint256 z) {
        assert((z = x * y) >= x);
    }

    function div(uint256 x, uint256 y) constant internal returns (uint256 z) {
        z = x / y;
    }

    function min(uint256 x, uint256 y) constant internal returns (uint256 z) {
        return x <= y ? x : y;
    }
    function max(uint256 x, uint256 y) constant internal returns (uint256 z) {
        return x >= y ? x : y;
    }
}

contract ITGTokenBase is ERC20, SafeMath {

                                        
  mapping(address => uint) balances;

                            
  mapping (address => mapping (address => uint)) allowed;

  
  function balanceOf(address _owner) constant returns (uint balance) {
    return balances[_owner];
  }

  function approve(address _spender, uint _value) returns (bool success) {

                                                                           
                                                                        
                                                                
                                                                         
    if ((_value != 0) && (allowed[msg.sender][_spender] != 0)) throw;

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) constant returns (uint remaining) {
    return allowed[_owner][_spender];
  }

}

contract Authable {
    address public owner;
    address public executor;

    modifier onlyOwner(){
        require(msg.sender == owner);
        _;
    }
   
    modifier onlyAuth(){
        require(msg.sender == owner || msg.sender == executor);
        _;
    }

    function setOwner(address _owner){
        require(owner == 0x0 || owner == msg.sender);
        owner = _owner;
    }

    function setExecutor(address exec) {
        require(executor == 0x0 || owner == msg.sender || executor == msg.sender);
        executor = exec;
    }
}

contract ITGToken is ITGTokenBase, Authable {
    bytes32  public  symbol = "ITG";
    uint256  public  decimals = 18;
    bytes32   public  name = "ITG";

    enum Status { CrowdSale, Game, Pause }
    Status public status;

    CrowdSale crowdSale;
    Games games;
    Voting voting;

    mapping(address => uint) public withdrawRestriction;

    uint public minEtherParticipate;
    uint public minTokParticipate;

    event LogFundTransfer(address sender, address to, uint amount, uint8 currency);

    modifier beforeTransfer(){
        require(withdrawRestriction[msg.sender] < now);
        _;
    }

    function transfer(address _to, uint _value) beforeTransfer returns (bool success) {
        balances[msg.sender] = sub(balances[msg.sender], _value);
        balances[_to] = add(balances[_to], _value);
        Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(address _from, address _to, uint _value) beforeTransfer returns (bool success) {
        uint _allowance = allowed[_from][msg.sender];

        balances[_to] = add(balances[_to], _value);
        balances[_from] = sub(balances[_from], _value);
        allowed[_from][msg.sender] = sub(_allowance, _value);
        Transfer(_from, _to, _value);
        return true;
    }

                                             
    function ITGToken() {
        owner = msg.sender;
        totalSupply = 100000000 * 1 ether;
        balances[msg.sender] = totalSupply;

        status = Status.Pause;
    }
    function () payable {
       if(msg.value < minEtherParticipate){
            throw;
       }

       if(status == Status.CrowdSale){
            LogFundTransfer(msg.sender, 0x0, msg.value, 1);
            itgTokenTransfer(crowdSale.process(msg.sender,msg.value),true);
       }else if(status == Status.Game){
            LogFundTransfer(msg.sender, 0x0, msg.value, 1);
            games.process(msg.sender, msg.value);
       }else if(status == Status.Pause){
            throw;
       }
    }

    function setAttrs(address csAddr, address gmAddr, address vtAddr, Status _status, uint amtEth, uint amtTok) onlyAuth {
        crowdSale = CrowdSale(csAddr);
        games = Games(gmAddr);
        voting = Voting(vtAddr);
        status = _status;
        minEtherParticipate = amtEth;
        minTokParticipate = amtTok;
    }

                       
    function USER_GET_CROWDSALE_TOKEN() {
        itgTokenTransfer(crowdSale.getToken(msg.sender),true);
    }

          
    function USER_VOTE(uint voteId, uint candidateId){
        uint addedToken;
        uint lockUntil;
        (addedToken, lockUntil) = voting.vote(msg.sender,balances[msg.sender],voteId,candidateId);
        itgTokenTransfer(addedToken,true);

        if(withdrawRestriction[msg.sender] < lockUntil){
            withdrawRestriction[msg.sender] = lockUntil;
        }
    }

    function voteInitiate(uint voteId, uint voteRewardPerUnit, uint voteWeightUnit, uint voteStart, uint voteEnd, uint maxCandidateId) onlyAuth {
        voting.voteInitiate(voteId, voteRewardPerUnit, voteWeightUnit, voteStart, voteEnd, maxCandidateId);
    }

    function itgTokenTransfer(uint amt, bool fromOwner) private {
        if(amt > 0){
            if(fromOwner){
                balances[owner] = sub(balances[owner], amt);
                balances[msg.sender] = add(balances[msg.sender], amt);
                Transfer(owner, msg.sender, amt);
                LogFundTransfer(owner, msg.sender, amt, 2);
            }else{
                balances[owner] = add(balances[owner], amt);
                balances[msg.sender] = sub(balances[msg.sender], amt);
                Transfer(msg.sender, owner, amt);
                LogFundTransfer(msg.sender, owner, amt, 2);
            }
        }
    }

    function ethTransfer(address target, uint amt) private {
        if(amt > 0){
            target.transfer(amt);
            LogFundTransfer(0x0, target, amt, 1);
        }
    }

                   
    function USER_GAME_WITH_TOKEN(uint tokenAmountToGame) {
        require(status == Status.Game);
        require(balances[msg.sender] >= tokenAmountToGame * 1 ether);
        require(tokenAmountToGame * 1 ether >= minTokParticipate);

        itgTokenTransfer(tokenAmountToGame * 1 ether,false);

        games.processWithITG(msg.sender, tokenAmountToGame * 1 ether);
        
    }

              
    function USER_GET_PRIZE() {
        uint ethPrize;
        uint tokPrize;
        (ethPrize, tokPrize) = games.getPrize(msg.sender);
        itgTokenTransfer(tokPrize,true);
        ethTransfer(msg.sender, ethPrize);
    }

    function selectWinner(uint rand) onlyAuth {
        games.selectWinner(rand);
    }

    function burn(uint amt) onlyOwner {
        balances[msg.sender] = sub(balances[msg.sender], amt);
        totalSupply = sub(totalSupply,amt);
    }

    function mint(uint amt) onlyOwner {
        balances[msg.sender] = add(balances[msg.sender], amt);
        totalSupply = add(totalSupply,amt);
    }

                                                                                       
                                                                                                              
                                                               
    function lossToCharity(uint year,address charityAccount) onlyAuth {
        ethTransfer(charityAccount, games.lossToCharity(year));
    }

    function charityAmtToCharity(address charityAccount) onlyOwner {
        ethTransfer(charityAccount, games.charityAmtToCharity());
    }

    function distributeTokenSale(uint hour, uint month, uint year, uint charity) onlyAuth{
        games.distributeTokenSale(hour, month, year, charity);
    }

}