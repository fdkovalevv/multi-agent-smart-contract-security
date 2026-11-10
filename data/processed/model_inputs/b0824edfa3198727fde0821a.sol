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
        require(newOwner != address(0));
        owner = newOwner;
    }

}

contract Pausable is Ownable {

    event Pause();

    event Unpause();

    bool public paused = false;

       
                                                                      
       
    modifier whenNotPaused() {
        require(!paused);
        _;
    }

       
                                                                          
       
    modifier whenPaused() {
        require(paused);
        _;
    }

       
                                                                
       
    function pause() onlyOwner whenNotPaused {
        paused = true;
        Pause();
    }

       
                                                                   
       
    function unpause() onlyOwner whenPaused {
        paused = false;
        Unpause();
    }

}

contract StagedCrowdsale is Pausable {

    using SafeMath for uint;

    struct Stage {
    uint hardcap;
    uint price;
    uint invested;
    uint closed;
    }

    uint public start;

    uint public period;

    uint public totalHardcap;

    uint public totalInvested;

    Stage[] public stages;

    function stagesCount() public constant returns(uint) {
        return stages.length;
    }

    function setStart(uint newStart) public onlyOwner {
        start = newStart;
    }

    function setPeriod(uint newPeriod) public onlyOwner {
        period = newPeriod;
    }

    function addStage(uint hardcap, uint price) public onlyOwner {
        require(hardcap > 0 && price > 0);
        Stage memory stage = Stage(hardcap.mul(1 ether), price, 0, 0);
        stages.push(stage);
        totalHardcap = totalHardcap.add(stage.hardcap);
    }

    function removeStage(uint8 number) public onlyOwner {
        require(number >=0 && number < stages.length);
        Stage storage stage = stages[number];
        totalHardcap = totalHardcap.sub(stage.hardcap);
        delete stages[number];
        for (uint i = number; i < stages.length - 1; i++) {
            stages[i] = stages[i+1];
        }
        stages.length--;
    }

    function changeStage(uint8 number, uint hardcap, uint price) public onlyOwner {
        require(number >= 0 &&number < stages.length);
        Stage storage stage = stages[number];
        totalHardcap = totalHardcap.sub(stage.hardcap);
        stage.hardcap = hardcap.mul(1 ether);
        stage.price = price;
        totalHardcap = totalHardcap.add(stage.hardcap);
    }

    function insertStage(uint8 numberAfter, uint hardcap, uint price) public onlyOwner {
        require(numberAfter < stages.length);
        Stage memory stage = Stage(hardcap.mul(1 ether), price, 0, 0);
        totalHardcap = totalHardcap.add(stage.hardcap);
        stages.length++;
        for (uint i = stages.length - 2; i > numberAfter; i--) {
            stages[i + 1] = stages[i];
        }
        stages[numberAfter + 1] = stage;
    }

    function clearStages() public onlyOwner {
        for (uint i = 0; i < stages.length; i++) {
            delete stages[i];
        }
        stages.length -= stages.length;
        totalHardcap = 0;
    }

    function lastSaleDate() public constant returns(uint) {
        return start + period * 1 days;
    }

    modifier saleIsOn() {
        require(stages.length > 0 && now >= start && now < lastSaleDate());
        _;
    }

    modifier isUnderHardcap() {
        require(totalInvested <= totalHardcap);
        _;
    }

    function currentStage() public saleIsOn isUnderHardcap constant returns(uint) {
        for(uint i=0; i < stages.length; i++) {
            if(stages[i].closed == 0) {
                return i;
            }
        }
        revert();
    }

}

contract CommonSale is StagedCrowdsale {

    address public multisigWallet;

    uint public minPrice;

    uint public totalTokensMinted;

    CovestingToken public token;

    function setMinPrice(uint newMinPrice) public onlyOwner {
        minPrice = newMinPrice;
    }

    function setMultisigWallet(address newMultisigWallet) public onlyOwner {
        multisigWallet = newMultisigWallet;
    }

    function setToken(address newToken) public onlyOwner {
        token = CovestingToken(newToken);
    }

    function createTokens() public whenNotPaused payable {
        require(msg.value >= minPrice);
        uint stageIndex = currentStage();
        multisigWallet.transfer(msg.value);
        Stage storage stage = stages[stageIndex];
        uint tokens = msg.value.mul(stage.price);
        token.mint(this, tokens);
        token.transfer(msg.sender, tokens);
        totalTokensMinted = totalTokensMinted.add(tokens);
        totalInvested = totalInvested.add(msg.value);
        stage.invested = stage.invested.add(msg.value);
        if(stage.invested >= stage.hardcap) {
            stage.closed = now;
        }
    }

    function() external payable {
        createTokens();
    }

    function retrieveTokens(address anotherToken) public onlyOwner {
        ERC20 alienToken = ERC20(anotherToken);
        alienToken.transfer(multisigWallet, token.balanceOf(this));
    }

}

contract Mainsale is CommonSale {

    enum Currency { BTC, LTC, ZEC, DASH, WAVES, USD, EUR }

    event ExternalSale(
        Currency _currency,
        bytes32 _txIdSha3,
        address indexed _buyer,
        uint256 _amountWei,
        uint256 _tokensE18
    );

    event NotifierChanged(
        address indexed _oldAddress,
        address indexed _newAddress
    );

                                                                         
    address public notifier;

                                                     
    mapping(uint8 => mapping(bytes32 => uint256)) public externalTxs;

                                                                                          
    uint256 public totalExternalSales = 0;

    modifier canNotify() {
        require(msg.sender == owner || msg.sender == notifier);
        _;
    }

                       

    address public foundersTokensWallet;

    address public bountyTokensWallet;

    uint public foundersTokensPercent;

    uint public bountyTokensPercent;

    uint public percentRate = 100;

    uint public lockPeriod;

    function setLockPeriod(uint newLockPeriod) public onlyOwner {
        lockPeriod = newLockPeriod;
    }

    function setFoundersTokensPercent(uint newFoundersTokensPercent) public onlyOwner {
        foundersTokensPercent = newFoundersTokensPercent;
    }

    function setBountyTokensPercent(uint newBountyTokensPercent) public onlyOwner {
        bountyTokensPercent = newBountyTokensPercent;
    }

    function setFoundersTokensWallet(address newFoundersTokensWallet) public onlyOwner {
        foundersTokensWallet = newFoundersTokensWallet;
    }

    function setBountyTokensWallet(address newBountyTokensWallet) public onlyOwner {
        bountyTokensWallet = newBountyTokensWallet;
    }

    function finishMinting() public whenNotPaused onlyOwner {
        uint summaryTokensPercent = bountyTokensPercent + foundersTokensPercent;
        uint mintedTokens = token.totalSupply();
        uint summaryFoundersTokens = mintedTokens.mul(summaryTokensPercent).div(percentRate - summaryTokensPercent);
        uint totalSupply = summaryFoundersTokens + mintedTokens;
        uint foundersTokens = totalSupply.mul(foundersTokensPercent).div(percentRate);
        uint bountyTokens = totalSupply.mul(bountyTokensPercent).div(percentRate);
        token.mint(this, foundersTokens);
        token.lock(foundersTokensWallet, lockPeriod * 1 days);
        token.transfer(foundersTokensWallet, foundersTokens);
        token.mint(this, bountyTokens);
        token.transfer(bountyTokensWallet, bountyTokens);
        totalTokensMinted = totalTokensMinted.add(foundersTokens).add(bountyTokens);
        token.finishMinting();
    }

                                                                            
                               

    function setNotifier(address _notifier) public onlyOwner {
        NotifierChanged(notifier, _notifier);
        notifier = _notifier;
    }

    function externalSales(
        uint8[] _currencies,
        bytes32[] _txIdSha3,
        address[] _buyers,
        uint256[] _amountsWei,
        uint256[] _tokensE18
    ) public whenNotPaused canNotify {

        require(_currencies.length > 0);
        require(_currencies.length == _txIdSha3.length);
        require(_currencies.length == _buyers.length);
        require(_currencies.length == _amountsWei.length);
        require(_currencies.length == _tokensE18.length);

        for (uint i = 0; i < _txIdSha3.length; i++) {
            _externalSaleSha3(
                Currency(_currencies[i]),
                _txIdSha3[i],
                _buyers[i],
                _amountsWei[i],
                _tokensE18[i]
            );
        }
    }

    function _externalSaleSha3(
        Currency _currency,
        bytes32 _txIdSha3,                                                    
        address _buyer,
        uint256 _amountWei,
        uint256 _tokensE18
    ) internal {

        require(_buyer > 0 && _amountWei > 0 && _tokensE18 > 0);

        var txsByCur = externalTxs[uint8(_currency)];

                                                                                   
        require(txsByCur[_txIdSha3] == 0);
        txsByCur[_txIdSha3] = _tokensE18;

        uint stageIndex = currentStage();
        Stage storage stage = stages[stageIndex];

        token.mint(this, _tokensE18);
        token.transfer(msg.sender, _tokensE18);
        totalTokensMinted = totalTokensMinted.add(_tokensE18);
        totalExternalSales++;

        totalInvested = totalInvested.add(_amountWei);
        stage.invested = stage.invested.add(_amountWei);
        if (stage.invested >= stage.hardcap) {
            stage.closed = now;
        }

        ExternalSale(_currency, _txIdSha3, _buyer, _amountWei, _tokensE18);
    }

                                                                            

    function btcId() public constant returns (uint8) {
        return uint8(Currency.BTC);
    }

    function ltcId() public constant returns (uint8) {
        return uint8(Currency.LTC);
    }

    function zecId() public constant returns (uint8) {
        return uint8(Currency.ZEC);
    }

    function dashId() public constant returns (uint8) {
        return uint8(Currency.DASH);
    }

    function wavesId() public constant returns (uint8) {
        return uint8(Currency.WAVES);
    }

    function usdId() public constant returns (uint8) {
        return uint8(Currency.USD);
    }

    function eurId() public constant returns (uint8) {
        return uint8(Currency.EUR);
    }

                                                                            

    function _tokensByTx(Currency _currency, string _txId) internal constant returns (uint256) {
        return tokensByTx(uint8(_currency), _txId);
    }

    function tokensByTx(uint8 _currency, string _txId) public constant returns (uint256) {
        return externalTxs[_currency][keccak256(_txId)];
    }

    function tokensByBtcTx(string _txId) public constant returns (uint256) {
        return _tokensByTx(Currency.BTC, _txId);
    }

    function tokensByLtcTx(string _txId) public constant returns (uint256) {
        return _tokensByTx(Currency.LTC, _txId);
    }

    function tokensByZecTx(string _txId) public constant returns (uint256) {
        return _tokensByTx(Currency.ZEC, _txId);
    }

    function tokensByDashTx(string _txId) public constant returns (uint256) {
        return _tokensByTx(Currency.DASH, _txId);
    }

    function tokensByWavesTx(string _txId) public constant returns (uint256) {
        return _tokensByTx(Currency.WAVES, _txId);
    }

    function tokensByUsdTx(string _txId) public constant returns (uint256) {
        return _tokensByTx(Currency.USD, _txId);
    }

    function tokensByEurTx(string _txId) public constant returns (uint256) {
        return _tokensByTx(Currency.EUR, _txId);
    }

                             
                                                                            
}