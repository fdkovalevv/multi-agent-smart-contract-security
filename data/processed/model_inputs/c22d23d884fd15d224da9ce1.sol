contract UnicornAccessControl {

    UnicornManagementInterface public unicornManagement;

    function UnicornAccessControl(address _unicornManagementAddress) public {
        unicornManagement = UnicornManagementInterface(_unicornManagementAddress);
        unicornManagement.registerInit(this);
    }

    modifier onlyOwner() {
        require(msg.sender == unicornManagement.ownerAddress());
        _;
    }

    modifier onlyManager() {
        require(msg.sender == unicornManagement.managerAddress());
        _;
    }

    modifier onlyCommunity() {
        require(msg.sender == unicornManagement.communityAddress());
        _;
    }

    modifier onlyTournament() {
        require(unicornManagement.isTournament(msg.sender));
        _;
    }

    modifier whenNotPaused() {
        require(!unicornManagement.paused());
        _;
    }

    modifier whenPaused {
        require(unicornManagement.paused());
        _;
    }


    modifier onlyManagement() {
        require(msg.sender == address(unicornManagement));
        _;
    }

    modifier onlyBreeding() {
        require(msg.sender == unicornManagement.unicornBreedingAddress());
        _;
    }

    modifier onlyGeneLab() {
        require(msg.sender == unicornManagement.geneLabAddress());
        _;
    }

    modifier onlyBlackBox() {
        require(msg.sender == unicornManagement.blackBoxAddress());
        _;
    }

    modifier onlyUnicornToken() {
        require(msg.sender == unicornManagement.unicornTokenAddress());
        _;
    }

    function isGamePaused() external view returns (bool) {
        return unicornManagement.paused();
    }
}

contract UnicornBreeding is UnicornAccessControl {
    using SafeMath for uint;
               
    UnicornTokenInterface public unicornToken;                 
    BlackBoxInterface public blackBox;

    event HybridizationAdd(uint indexed unicornId, uint price);
    event HybridizationAccept(uint indexed firstUnicornId, uint indexed secondUnicornId, uint newUnicornId);
    event HybridizationDelete(uint indexed unicornId);
    event FundsTransferred(address dividendManager, uint value);
    event CreateUnicorn(address indexed owner, uint indexed unicornId, uint parent1, uint  parent2);
    event NewGen0Limit(uint limit);
    event NewGen0Step(uint step);


    event OfferAdd(uint256 indexed unicornId, uint price);
    event OfferDelete(uint256 indexed unicornId);
    event UnicornSold(uint256 indexed unicornId);

    ERC20 public candyToken;
    ERC20 public candyPowerToken;

                      
    uint public gen0Limit = 30000;
    uint public gen0Count = 0;
    uint public gen0Step = 1000;

                              
    uint public gen0PresaleLimit = 1000;
    uint public gen0PresaleCount = 0;

    struct Hybridization{
        uint listIndex;
        uint price;
        bool exists;
    }

                                                      
    mapping (uint => Hybridization) public hybridizations;
    mapping(uint => uint) public hybridizationList;
    uint public hybridizationListSize = 0;


    function() public payable {

    }

    function UnicornBreeding(address _unicornManagementAddress) UnicornAccessControl(_unicornManagementAddress) public {
        candyToken = ERC20(unicornManagement.candyToken());

    }

    function init() onlyManagement whenPaused external {
        unicornToken = UnicornTokenInterface(unicornManagement.unicornTokenAddress());
        blackBox = BlackBoxInterface(unicornManagement.blackBoxAddress());
        candyPowerToken = ERC20(unicornManagement.candyPowerToken());
    }

    function makeHybridization(uint _unicornId, uint _price) public {
        require(unicornToken.owns(msg.sender, _unicornId));
        require(unicornToken.isUnfreezed(_unicornId));
        require(!hybridizations[_unicornId].exists);

        hybridizations[_unicornId] = Hybridization({
            price: _price,
            exists: true,
            listIndex: hybridizationListSize
            });
        hybridizationList[hybridizationListSize++] = _unicornId;

        emit HybridizationAdd(_unicornId, _price);
    }


    function acceptHybridization(uint _firstUnicornId, uint _secondUnicornId) whenNotPaused public payable {
        require(unicornToken.owns(msg.sender, _secondUnicornId));
        require(_secondUnicornId != _firstUnicornId);
        require(unicornToken.isUnfreezed(_firstUnicornId) && unicornToken.isUnfreezed(_secondUnicornId));
        require(hybridizations[_firstUnicornId].exists);
        require(msg.value == unicornManagement.oraclizeFee());
        if (hybridizations[_firstUnicornId].price > 0) {
            require(candyToken.transferFrom(msg.sender, this, getHybridizationPrice(_firstUnicornId)));
        }

        plusFreezingTime(_secondUnicornId);
        uint256 newUnicornId = unicornToken.createUnicorn(msg.sender);
        blackBox.geneCore.value(unicornManagement.oraclizeFee())(newUnicornId, _firstUnicornId, _secondUnicornId);
        emit CreateUnicorn(msg.sender, newUnicornId, _firstUnicornId, _secondUnicornId);
        if (hybridizations[_firstUnicornId].price > 0) {
            candyToken.transfer(unicornToken.ownerOf(_firstUnicornId), hybridizations[_firstUnicornId].price);
        }
        emit HybridizationAccept(_firstUnicornId, _secondUnicornId, newUnicornId);
        _deleteHybridization(_firstUnicornId);
    }


    function cancelHybridization (uint _unicornId) public {
        require(unicornToken.owns(msg.sender,_unicornId));
        require(hybridizations[_unicornId].exists);
        _deleteHybridization(_unicornId);
    }

    function deleteHybridization(uint _unicornId) onlyUnicornToken external {
        _deleteHybridization(_unicornId);
    }

    function _deleteHybridization(uint _unicornId) internal {
        if (hybridizations[_unicornId].exists) {
            hybridizations[hybridizationList[--hybridizationListSize]].listIndex = hybridizations[_unicornId].listIndex;
            hybridizationList[hybridizations[_unicornId].listIndex] = hybridizationList[hybridizationListSize];
            delete hybridizationList[hybridizationListSize];
            delete hybridizations[_unicornId];
            emit HybridizationDelete(_unicornId);
        }
    }

                      
    function createUnicorn() public payable whenNotPaused returns(uint256)   {
        require(msg.value == getCreateUnicornPrice());
        return _createUnicorn(msg.sender);
    }

    function createUnicornForCandy() public payable whenNotPaused returns(uint256)   {
        require(msg.value == unicornManagement.oraclizeFee());
        require(candyToken.transferFrom(msg.sender, this, getCreateUnicornPriceInCandy()));
        return _createUnicorn(msg.sender);
    }

    function createPresaleUnicorns(uint _count, address _owner) public payable onlyManager whenPaused returns(bool) {
        require(gen0PresaleCount.add(_count) <= gen0PresaleLimit);
        uint256 newUnicornId;
        address owner = _owner == address(0) ? msg.sender : _owner;
        for (uint i = 0; i < _count; i++){
            newUnicornId = unicornToken.createUnicorn(owner);
            blackBox.createGen0(newUnicornId);
            emit CreateUnicorn(owner, newUnicornId, 0, 0);
            gen0Count = gen0Count.add(1);
            gen0PresaleCount = gen0PresaleCount.add(1);
        }
        return true;
    }

    function _createUnicorn(address _owner) private returns(uint256) {
        require(gen0Count < gen0Limit);
        uint256 newUnicornId = unicornToken.createUnicorn(_owner);
        blackBox.createGen0.value(unicornManagement.oraclizeFee())(newUnicornId);
        emit CreateUnicorn(_owner, newUnicornId, 0, 0);
        gen0Count = gen0Count.add(1);
        return newUnicornId;
    }

    function plusFreezingTime(uint _unicornId) private {
        unicornToken.plusFreezingTime(_unicornId);
    }

    function plusTourFreezingTime(uint _unicornId) onlyTournament public {
        unicornToken.plusTourFreezingTime(_unicornId);
    }

                                    
    function minusFreezingTime(uint _unicornId) public {
        require(candyPowerToken.transferFrom(msg.sender, this, unicornManagement.subFreezingPrice()));
        unicornToken.minusFreezingTime(_unicornId, unicornManagement.subFreezingTime());
    }

                                         
    function minusTourFreezingTime(uint _unicornId) public {
        require(candyPowerToken.transferFrom(msg.sender, this, unicornManagement.subTourFreezingPrice()));
        unicornToken.minusTourFreezingTime(_unicornId, unicornManagement.subTourFreezingTime());
    }

    function getHybridizationPrice(uint _unicornId) public view returns (uint) {
        return unicornManagement.getHybridizationFullPrice(hybridizations[_unicornId].price);
    }

    function getEtherFeeForPriceInCandy() public view returns (uint) {
        return unicornManagement.oraclizeFee();
    }

    function getCreateUnicornPriceInCandy() public view returns (uint) {
        return unicornManagement.getCreateUnicornFullPriceInCandy();
    }


    function getCreateUnicornPrice() public view returns (uint) {
        return unicornManagement.getCreateUnicornFullPrice();
    }


    function withdrawTokens() onlyManager public {
        require(candyToken.balanceOf(this) > 0 || candyPowerToken.balanceOf(this) > 0);
        if (candyToken.balanceOf(this) > 0) {
            candyToken.transfer(unicornManagement.walletAddress(), candyToken.balanceOf(this));
        }
        if (candyPowerToken.balanceOf(this) > 0) {
            candyPowerToken.transfer(unicornManagement.walletAddress(), candyPowerToken.balanceOf(this));
        }
    }


    function transferEthersToDividendManager(uint _value) onlyManager public {
        require(address(this).balance >= _value);
        DividendManagerInterface dividendManager = DividendManagerInterface(unicornManagement.dividendManagerAddress());
        dividendManager.payDividend.value(_value)();
        emit FundsTransferred(unicornManagement.dividendManagerAddress(), _value);
    }


    function setGen0Limit() external onlyCommunity {
        require(gen0Count == gen0Limit);
        gen0Limit = gen0Limit.add(gen0Step);
        emit NewGen0Limit(gen0Limit);
    }

    function setGen0Step(uint _step) external onlyCommunity {
        gen0Step = _step;
        emit NewGen0Step(gen0Limit);
    }





              
    struct Offer{
        uint marketIndex;
        uint price;
        bool exists;
    }

                                              
    mapping (uint => Offer) public offers;
                              
    mapping(uint => uint) public market;
    uint public marketSize = 0;


    function sellUnicorn(uint _unicornId, uint _price) public {
        require(unicornToken.owns(msg.sender, _unicornId));
        require(!offers[_unicornId].exists);

        offers[_unicornId] = Offer({
            price: _price,
            exists: true,
            marketIndex: marketSize
            });

        market[marketSize++] = _unicornId;

        emit OfferAdd(_unicornId, _price);
    }


    function buyUnicorn(uint _unicornId) public payable {
        require(offers[_unicornId].exists);
        uint price = offers[_unicornId].price;
        require(msg.value == unicornManagement.getSellUnicornFullPrice(price));

        address owner = unicornToken.ownerOf(_unicornId);

        emit UnicornSold(_unicornId);
                                               
        unicornToken.marketTransfer(owner, msg.sender, _unicornId);
        owner.transfer(price);
                                   
    }


    function revokeUnicorn(uint _unicornId) public {
        require(unicornToken.owns(msg.sender, _unicornId));
        require(offers[_unicornId].exists);
        _deleteOffer(_unicornId);
    }


    function deleteOffer(uint _unicornId) onlyUnicornToken external {
        _deleteOffer(_unicornId);
    }


    function _deleteOffer(uint _unicornId) internal {
        if (offers[_unicornId].exists) {
            offers[market[--marketSize]].marketIndex = offers[_unicornId].marketIndex;
            market[offers[_unicornId].marketIndex] = market[marketSize];
            delete market[marketSize];
            delete offers[_unicornId];
            emit OfferDelete(_unicornId);
        }
    }

    function getOfferPrice(uint _unicornId) public view returns (uint) {
        return unicornManagement.getSellUnicornFullPrice(offers[_unicornId].price);
    }

}