contract SafeMath {

    function safeMul(uint256 a, uint256 b) internal constant returns (uint256 ) {
        uint256 c = a * b;
        assert(a == 0 || c / a == b);
        return c;
    }

    function safeDiv(uint256 a, uint256 b) internal constant returns (uint256 ) {
        assert(b > 0);
        uint256 c = a / b;
        assert(a == b * c + a % b);
        return c;
    }

    function safeSub(uint256 a, uint256 b) internal constant returns (uint256 ) {
        assert(b <= a);
        return a - b;
    }

    function safeAdd(uint256 a, uint256 b) internal constant returns (uint256 ) {
        uint256 c = a + b;
        assert(c >= a);
        return c;
    }
}

contract Ownable {

    address public owner;
    address public pendingOwner;

    function Ownable() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

                                                                                                                        
    function transferOwnership(address newOwner) onlyOwner {
        pendingOwner = newOwner;
    }

    function claimOwnership() {
        if (msg.sender == pendingOwner) {
            owner = pendingOwner;
            pendingOwner = 0;
        }
    }
}

contract Pausable is Ownable {

    bool public paused;

    modifier ifNotPaused {
        require(!paused);
        _;
    }

    modifier ifPaused {
        require(paused);
        _;
    }

                                                              
    function pause() external onlyOwner {
        paused = true;
    }

                                                                       
    function resume() external onlyOwner ifPaused {
        paused = false;
    }
}

contract CommonBsPresale is SafeMath, Ownable, Pausable {

    enum Currency { BTC, LTC, ZEC, DASH, WAVES, USD, EUR }

                            

    struct Backer {
        uint256 weiReceived;                                 
        uint256 tokensSent;                                                                    
    }

                             

                                    
    mapping(address => Backer) public backers;

                                           
    mapping(uint8 => mapping(bytes32 => uint256)) public externalTxs;

    CommonBsToken public token;                             
    address public beneficiary;                                                               
    address public notifier;                                                                         

    uint256 public minTokensToBuy = 50 * 1e18;                      
    uint256 public maxCapWei      = 50000 ether;

    uint public tokensPerWei         = 1000;                                        
    uint public tokensPerWeiBonus333 = 1333;
    uint public tokensPerWeiBonus250 = 1250;
    uint public tokensPerWeiBonus111 = 1111;

    uint public startTime       = 1510160700;                        
    uint public bonusEndTime333 = 1510333500;                        
    uint public bonusEndTime250 = 1510679100;                        
    uint public endTime         = 1511024700;                        

                                  

                                  
    uint256 public totalWei           = 0;                      

    uint256 public totalTokensSold    = 0;                                                      
    uint256 public totalEthSales      = 0;                                                            
    uint256 public totalExternalSales = 0;                                                                                       
    uint256 public weiReceived        = 0;                                                                      

    uint public finalizedTime = 0;                                              

    bool public saleEnabled = true;                                                                      

    event BeneficiaryChanged(address indexed _oldAddress, address indexed _newAddress);
    event NotifierChanged(address indexed _oldAddress, address indexed _newAddress);

    event EthReceived(address indexed _buyer, uint256 _amountWei);
    event ExternalSaleSha3(Currency _currency, bytes32 _txIdSha3, address indexed _buyer, uint256 _amountWei, uint256 _tokensE18);

    modifier respectTimeFrame() {
        require(isSaleOn());
        _;
    }

    modifier canNotify() {
        require(msg.sender == owner || msg.sender == notifier);
        _;
    }

    function CommonBsPresale(address _token, address _beneficiary) {
        token = CommonBsToken(_token);
        owner = msg.sender;
        notifier = owner;
        beneficiary = _beneficiary;
    }

                                                 
    function getNow() public constant returns (uint) {
        return now;
    }

    function setSaleEnabled(bool _enabled) public onlyOwner {
        saleEnabled = _enabled;
    }

    function setBeneficiary(address _beneficiary) public onlyOwner {
        BeneficiaryChanged(beneficiary, _beneficiary);
        beneficiary = _beneficiary;
    }

    function setNotifier(address _notifier) public onlyOwner {
        NotifierChanged(notifier, _notifier);
        notifier = _notifier;
    }

      
                                                             
       
    function() public payable {
        if (saleEnabled) sellTokensForEth(msg.sender, msg.value);
    }

    function sellTokensForEth(address _buyer, uint256 _amountWei) internal ifNotPaused respectTimeFrame {

        totalWei = safeAdd(totalWei, _amountWei);
        weiReceived = safeAdd(weiReceived, _amountWei);
        require(totalWei <= maxCapWei);                       

        uint256 tokensE18 = weiToTokens(_amountWei);
        require(tokensE18 >= minTokensToBuy);

        require(token.sell(_buyer, tokensE18));                             
        totalTokensSold = safeAdd(totalTokensSold, tokensE18);
        totalEthSales++;

        Backer backer = backers[_buyer];
        backer.tokensSent = safeAdd(backer.tokensSent, tokensE18);
        backer.weiReceived = safeAdd(backer.weiReceived, _amountWei);                                                                           

        EthReceived(_buyer, _amountWei);
    }

                                                        
    function weiToTokens(uint256 _amountWei) public constant returns (uint256) {
        return weiToTokensAtTime(_amountWei, getNow());
    }

    function weiToTokensAtTime(uint256 _amountWei, uint _time) public constant returns (uint256) {
        uint256 rate = tokensPerWei;

        if (startTime <= _time && _time < bonusEndTime333) rate = tokensPerWeiBonus333;
        else if (bonusEndTime333 <= _time && _time < bonusEndTime250) rate = tokensPerWeiBonus250;
        else if (bonusEndTime250 <= _time && _time < endTime) rate = tokensPerWeiBonus111;

        return safeMul(_amountWei, rate);
    }

                                                                            
                               

    function externalSales(
        uint8[] _currencies,
        bytes32[] _txIdSha3,
        address[] _buyers,
        uint256[] _amountsWei,
        uint256[] _tokensE18
    ) public ifNotPaused canNotify {

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

        totalWei = safeAdd(totalWei, _amountWei);
        require(totalWei <= maxCapWei);                                      

        require(token.sell(_buyer, _tokensE18));                             
        totalTokensSold = safeAdd(totalTokensSold, _tokensE18);
        totalExternalSales++;

        txsByCur[_txIdSha3] = _tokensE18;
        ExternalSaleSha3(_currency, _txIdSha3, _buyer, _amountWei, _tokensE18);
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

                             
                                                                            

    function totalSales() public constant returns (uint256) {
        return safeAdd(totalEthSales, totalExternalSales);
    }

    function isMaxCapReached() public constant returns (bool) {
        return totalWei >= maxCapWei;
    }

    function isSaleOn() public constant returns (bool) {
        uint _now = getNow();
        return startTime <= _now && _now <= endTime;
    }

    function isSaleOver() public constant returns (bool) {
        return getNow() > endTime;
    }

    function isFinalized() public constant returns (bool) {
        return finalizedTime > 0;
    }

      
                                                                                                                           
       
    function finalize() public onlyOwner {

                                                                                
        require(isMaxCapReached() || isSaleOver());

        beneficiary.transfer(this.balance);

        finalizedTime = getNow();
    }
}

contract BsPresale is CommonBsPresale {

    function BsPresale() CommonBsPresale(
        0x7aa43ef8aa1829fce420fd1f9e6ebbe2212b3e06,                       
        0x76CA9140540988d36f7be7A8b1172E09E6d8A26c                              
    ) {}
}