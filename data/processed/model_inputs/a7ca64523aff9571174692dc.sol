contract ElecApprover {
    ElecWhitelist public list;
    mapping(address=>uint)    public participated;

    uint                      public saleStartTime;
    uint                      public firstRoundTime;
    uint                      public saleEndTime;
    uint                      public xtime = 5;                    

    using SafeMath for uint;


    function ElecApprover( ElecWhitelist _whitelistContract,
    uint                      _saleStartTime,
    uint                      _firstRoundTime,
    uint                      _saleEndTime ) public {
        list = _whitelistContract;
        saleStartTime = _saleStartTime;
        firstRoundTime = _firstRoundTime;
        saleEndTime = _saleEndTime;

        require( list != ElecWhitelist(0x0) );
        require( saleStartTime < firstRoundTime );
        require(  firstRoundTime < saleEndTime );
    }

                                                                                 
    function contributorCap( address contributor ) public constant returns(uint) {
        uint  cap= list.getCap( contributor );
        uint higherCap = cap;

        if ( now > firstRoundTime ) {
            higherCap = cap.mul(xtime);
        }
        return higherCap;
    }


    function eligible( address contributor, uint amountInWei ) public constant returns(uint) {
        if( now < saleStartTime ) return 0;
        if( now >= saleEndTime ) return 0;

        uint cap = list.getCap( contributor );

        if( cap == 0 ) return 0;

        uint higherCap = cap;
        if ( now > firstRoundTime ) {
            higherCap = cap.mul(xtime);
        }

        uint remainedCap = higherCap.sub(participated[ contributor ]);
        if( remainedCap > amountInWei ) return amountInWei;
              else return remainedCap;

    }

    function eligibleTestAndIncrement( address contributor, uint amountInWei ) internal returns(uint) {
        uint result = eligible( contributor, amountInWei );
        if ( result > 0) {
            participated[contributor] = participated[contributor].add( result );
        }
        return result;
    }


    function contributedCap(address _contributor) public constant returns(uint) {
        if (participated[_contributor] == 0 ) return 0;

        return participated[_contributor];
    }

     function contributedInternalCap(address _contributor) view internal returns(uint) {
         if (participated[_contributor] == 0 ) return 0;

        return participated[_contributor];
    }


    function saleEnded() public constant returns(bool) {
        return now > saleEndTime;
    }

    function saleStarted() public constant returns(bool) {
        return now >= saleStartTime;
    }
}

contract ElecSaleSmartContract is ElecApprover{
    address             public admin;
    address             public multiSigWallet;                          
    ElecTokenSmartContract public token;
    uint                public raisedWei;
    bool                public haltSale;
    uint                constant toWei = (10**18);
    uint                public minCap = toWei.div(2);

    mapping(bytes32=>uint) public proxyPurchases;

    function ElecSaleSmartContract( address _admin,
    address _multiSigWallet,
    ElecWhitelist _whiteListContract,
    uint _totalTokenSupply,
    uint _companyTokenSupply,
    uint _saleStartTime,
    uint _firstRoundTime,
    uint _saleEndTime,
    uint _lockedDays)

    public

    ElecApprover( _whiteListContract,
    _saleStartTime,
    _firstRoundTime,
    _saleEndTime )
    {
        admin = _admin;
        multiSigWallet = _multiSigWallet;

        token = new ElecTokenSmartContract( _totalTokenSupply,
        _saleStartTime,
        _saleEndTime,
        _lockedDays,                                    
        _admin );

                                                      
        token.transfer( multiSigWallet, _companyTokenSupply );
    }

    function setHaltSale( bool halt ) public {
        require( msg.sender == admin );
        haltSale = halt;
    }

    function() public payable {
        buy( msg.sender );
    }

    event ProxyBuy( bytes32 indexed _proxy, address _recipient, uint _amountInWei );
    function proxyBuy( bytes32 proxy, address recipient ) public payable returns(uint){
        uint amount = buy( recipient );
        proxyPurchases[proxy] = proxyPurchases[proxy].add(amount);
        ProxyBuy( proxy, recipient, amount );


        return amount;
    }

    event Buy( address _buyer, uint _tokens, uint _payedWei );
    function buy( address recipient ) public payable returns(uint){
        require( tx.gasprice <= 50000000000 wei );

        require( ! haltSale );
        require( saleStarted() );
        require( ! saleEnded() );

                                          
        uint weiContributedCap = contributedInternalCap(recipient);

        if (weiContributedCap == 0 ) require( msg.value >= minCap);



        uint weiPayment = eligibleTestAndIncrement( recipient, msg.value );

        require( weiPayment > 0 );


                                               
        if( msg.value > weiPayment ) {
            msg.sender.transfer( msg.value.sub( weiPayment ) );
        }

                                 
        sendETHToMultiSig( weiPayment );
        raisedWei = raisedWei.add( weiPayment );
        uint recievedTokens = weiPayment.mul( 5000 );

        assert( token.transfer( recipient, recievedTokens ) );


        Buy( recipient, recievedTokens, weiPayment );

        return weiPayment;
    }

    function sendETHToMultiSig( uint value ) internal {
        multiSigWallet.transfer( value );
    }

    event FinalizeSale();
                                       
    function finalizeSale() public {
        require( saleEnded() );
        require( msg.sender == admin );

                                
        token.burn(token.balanceOf(this));

        FinalizeSale();
    }

                                              
                                                                                 
    function emergencyDrain(ERC20 anyToken) public returns(bool){
        require( msg.sender == admin );
        require( saleEnded() );

        if( this.balance > 0 ) {
            sendETHToMultiSig( this.balance );
        }

        if( anyToken != address(0x0) ) {
            assert( anyToken.transfer(multiSigWallet, anyToken.balanceOf(this)) );
        }

        return true;
    }

                                                       
                                     
                                          
                                    
                                       
       
}