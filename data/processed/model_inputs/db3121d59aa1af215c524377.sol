contract MultiOwnable {
    mapping (address => bool) public ownerRegistry;
    address[] owners;
    address public multiOwnableCreator = 0x0;

    function MultiOwnable() public {
        multiOwnableCreator = msg.sender;
    }

    function setupOwners(address[] _owners) public {
                                                        
        require(multiOwnableCreator == msg.sender);
        require(owners.length == 0);
        for(uint256 idx=0; idx < _owners.length; idx++) {
            require(
                !ownerRegistry[_owners[idx]] &&
                _owners[idx] != 0x0 &&
                _owners[idx] != address(this)
            );
            ownerRegistry[_owners[idx]] = true;
        }
        owners = _owners;
    }

    modifier onlyOwner() {
        require(ownerRegistry[msg.sender] == true);
        _;
    }

    function getOwners() public constant returns (address[]) {
        return owners;
    }
}

contract Treasury is MultiOwnable {
    using SafeMath for uint256;

                                       
    uint256 public weiWithdrawed = 0;

                                    
    uint256 public weiUnlocked = 0;

                                                      
    bool public isCrowdsaleFinished = false;

                                              
    address teamWallet = 0x0;

                                 
    EthearnalRepTokenCrowdsale public crowdsaleContract;
    EthearnalRepToken public tokenContract;
    bool public isRefundsEnabled = false;

                                                                       
    uint256 public withdrawChunk = 0;
    VotingProxy public votingProxyContract;
    uint256 public refundsIssued = 0;
    uint256 public percentLeft = 0;


    event Deposit(uint256 amount);
    event Withdraw(uint256 amount);
    event UnlockWei(uint256 amount);
    event RefundedInvestor(address indexed investor, uint256 amountRefunded, uint256 tokensBurn);

    function Treasury(address _teamWallet) public {
        require(_teamWallet != 0x0);
                                        
        teamWallet = _teamWallet;
    }

             
    function() public payable {
        require(msg.sender == address(crowdsaleContract));
        Deposit(msg.value);
    }

    function setVotingProxy(address _votingProxyContract) public onlyOwner {
        require(votingProxyContract == address(0x0));
        votingProxyContract = VotingProxy(_votingProxyContract);
    }

             
    function setCrowdsaleContract(address _address) public onlyOwner {
                                 
        require(crowdsaleContract == address(0x0));
        require(_address != 0x0);
        crowdsaleContract = EthearnalRepTokenCrowdsale(_address); 
    }

    function setTokenContract(address _address) public onlyOwner {
                                 
        require(tokenContract == address(0x0));
        require(_address != 0x0);
        tokenContract = EthearnalRepToken(_address);
    }

             
    function setCrowdsaleFinished() public {
        require(crowdsaleContract != address(0x0));
        require(msg.sender == address(crowdsaleContract));
        withdrawChunk = getWeiRaised().div(10);
        weiUnlocked = withdrawChunk;
        isCrowdsaleFinished = true;
    }

             
    function withdrawTeamFunds() public onlyOwner {
        require(isCrowdsaleFinished);
        require(weiUnlocked > weiWithdrawed);
        uint256 toWithdraw = weiUnlocked.sub(weiWithdrawed);
        weiWithdrawed = weiUnlocked;
        teamWallet.transfer(toWithdraw);
        Withdraw(toWithdraw);
    }

    function getWeiRaised() public constant returns(uint256) {
       return crowdsaleContract.weiRaised();
    }

    function increaseWithdrawalChunk() {
        require(isCrowdsaleFinished);
        require(msg.sender == address(votingProxyContract));
        weiUnlocked = weiUnlocked.add(withdrawChunk);
        UnlockWei(weiUnlocked);
    }

    function getTime() internal returns (uint256) {
                                   
                                                                                
                                                                        
        return now;
    }

    function enableRefunds() public {
        require(msg.sender == address(votingProxyContract));
        isRefundsEnabled = true;
    }
    
    function refundInvestor(uint256 _tokensToBurn) public {
        require(isRefundsEnabled);
        require(address(tokenContract) != address(0x0));
        if (refundsIssued == 0) {
            percentLeft = percentLeftFromTotalRaised().mul(100*1000).div(1 ether);
        }
        uint256 tokenRate = crowdsaleContract.getTokenRateEther();
        uint256 toRefund = tokenRate.mul(_tokensToBurn).div(1 ether);
        
        toRefund = toRefund.mul(percentLeft).div(100*1000);
        require(toRefund > 0);
        tokenContract.burnFrom(msg.sender, _tokensToBurn);
        msg.sender.transfer(toRefund);
        refundsIssued = refundsIssued.add(1);
        RefundedInvestor(msg.sender, toRefund, _tokensToBurn);
    }

    function percentLeftFromTotalRaised() public constant returns(uint256) {
        return percent(this.balance, getWeiRaised(), 18);
    }

    function percent(uint numerator, uint denominator, uint precision) internal constant returns(uint quotient) {
                                               
        uint _numerator  = numerator * 10 ** (precision+1);
                                      
        uint _quotient =  ((_numerator / denominator) + 5) / 10;
        return ( _quotient);
    }

    function claimTokens(address _token, address _to) public onlyOwner {    
        ERC20Basic token = ERC20Basic(_token);
        uint256 balance = token.balanceOf(this);
        token.transfer(_to, balance);
    }
}