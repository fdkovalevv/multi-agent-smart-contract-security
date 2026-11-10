contract Ambassador {
    using SafeMath for uint256;
    CoinCrowdICO icoContract;
    uint256 public startRC;
    uint256 public endRC;
    address internal contractOwner; 
    
    uint256 public soldTokensWithoutBonus;                                         
	function euroRaisedRc() public view returns(uint256 euro) {
        return icoContract.euroRaised(soldTokensWithoutBonus);
    }
    
    uint256[] public euroThreshold;                                                        
    uint256[] public bonusThreshold;                                                             
    
    mapping(address => uint256) public balanceUser;                           

    function Ambassador(address _icoContract, address _ambassadorAddr, uint256[] _euroThreshold, uint256[] _bonusThreshold, uint256 _startRC , uint256 _endRC ) public {
        require ( _icoContract != 0 );
        require ( _ambassadorAddr != 0 );
        require ( _euroThreshold.length != 0 );
        require ( _euroThreshold.length == _bonusThreshold.length );
        
        icoContract = CoinCrowdICO(_icoContract);
        contractOwner = _icoContract;
        
        icoContract.addMeByRC(_ambassadorAddr);
        
        bonusThreshold = _bonusThreshold;
        euroThreshold = _euroThreshold;
        
        soldTokensWithoutBonus = 0;
        
        setTimeRC( _startRC, _endRC );
    }
    
    modifier onlyIcoContract() {
        require(msg.sender == contractOwner);
        _;
    }
    
    function setTimeRC(uint256 _startRC, uint256 _endRC ) internal {
        if( _startRC == 0 ) {
            startRC = icoContract.startTime();
        } else {
            startRC = _startRC;
        }
        if( _endRC == 0 ) {
            endRC = icoContract.endTime();
        } else {
            endRC = _endRC;
        }
    }
    
    function updateTime(uint256 _newStart, uint256 _newEnd) public onlyIcoContract {
        if ( _newStart != 0 ) startRC = _newStart;
        if ( _newEnd != 0 ) endRC = _newEnd;
    }

    function () public payable {
        require( now > startRC );
        if( now < endRC ) {
            uint256 tokenAmount = icoContract.buy.value(msg.value)(msg.sender);
            balanceUser[msg.sender] = balanceUser[msg.sender].add(tokenAmount);
            soldTokensWithoutBonus = soldTokensWithoutBonus.add(tokenAmount);
        } else {                            
            require( balanceUser[msg.sender] > 0 );
            uint256 bonusApplied = 0;
            for (uint i = 0; i < euroThreshold.length; i++) {
                if ( icoContract.euroRaised(soldTokensWithoutBonus).div(1000) > euroThreshold[i] ) {
                    bonusApplied = bonusThreshold[i];
                }
            }    
            require( bonusApplied > 0 );
            
            uint256 addTokenAmount = balanceUser[msg.sender].mul( bonusApplied ).div(10**2);
            balanceUser[msg.sender] = 0; 
            
            icoContract.claimPremium(msg.sender, addTokenAmount);
            if( msg.value > 0 ) msg.sender.transfer(msg.value);                  
        }
    }
}