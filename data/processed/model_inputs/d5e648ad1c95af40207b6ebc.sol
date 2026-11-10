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

contract BBDExchange is Ownable {
    using SafeMath for uint256;

    uint256 public constant startTime = 1506844800;                                      
    uint256 public constant endTime = 1509523200;                                            

    BBDToken private bbdToken;

             
    event LogSell(address indexed _seller, uint256 _value, uint256 _amount);
    event LogBuy(address indexed _purchaser, uint256 _value, uint256 _amount);

                                     
    modifier onlyWhenICOReachedCreationMinCap() {
        require(bbdToken.totalSupply() >= bbdToken.creationMinCap());
        _;
    }

    function() payable {}

    function Exchange(address bbdTokenAddress) {
        bbdToken = BBDToken(bbdTokenAddress);
    }

                                    
    function exchangeRate() constant returns (uint256){
        return bbdToken.creationRateOnTime().mul(100).div(93);                                         
    }

                                       
    function exchangeBBDBalance() constant returns (uint256){
        return bbdToken.balanceOf(this);
    }

                                                   
    function maxSell() constant returns (uint256 valueBbd) {
        valueBbd = this.balance.mul(exchangeRate());
    }

                                           
    function maxBuy() constant returns (uint256 valueInEthWei) {
        valueInEthWei = exchangeBBDBalance().div(exchangeRate());
    }

                                
    function checkSell(uint256 _valueBbd) constant returns (bool isPossible, uint256 valueInEthWei) {
        valueInEthWei = _valueBbd.div(exchangeRate());
        isPossible = this.balance >= valueInEthWei ? true : false;
    }

                               
    function checkBuy(uint256 _valueInEthWei) constant returns (bool isPossible, uint256 valueBbd) {
        valueBbd = _valueInEthWei.mul(exchangeRate());
        isPossible = exchangeBBDBalance() >= valueBbd ? true : false;
    }

               
    function sell(uint256 _valueBbd) onlyWhenICOReachedCreationMinCap external {
        require(_valueBbd > 0);
        require(now >= startTime);
        require(now <= endTime);
        require(_valueBbd <= bbdToken.balanceOf(msg.sender));

        uint256 checkedEth = _valueBbd.div(exchangeRate());
        require(checkedEth <= this.balance);

                                                   
        require(bbdToken.transferToExchange(msg.sender, _valueBbd));
        msg.sender.transfer(checkedEth);

        LogSell(msg.sender, checkedEth, _valueBbd);
    }

              
    function buy() onlyWhenICOReachedCreationMinCap payable external {
        require(msg.value != 0);
        require(now >= startTime);
        require(now <= endTime);

        uint256 checkedBBDTokens = msg.value.mul(exchangeRate());
        require(checkedBBDTokens <= exchangeBBDBalance());

                                
        require(bbdToken.transfer(msg.sender, checkedBBDTokens));

        LogBuy(msg.sender, msg.value, checkedBBDTokens);
    }

                     
    function close() onlyOwner {
        require(now >= endTime);

                                       
        require(bbdToken.transfer(owner, exchangeBBDBalance()));
        owner.transfer(this.balance);
    }
}