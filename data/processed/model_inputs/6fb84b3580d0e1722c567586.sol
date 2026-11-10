contract swap{
    address public beneficiary;
    TokenInterface public tokenObj;
    uint public price_token;
    uint256 public WEI_PER_FINNEY = 1000000000000000;
    uint public BILLION = 1000000000;
    uint public expiryDate;
    
                                                                              
    function swap(address sendEtherTo, address adddressOfToken, uint tokenPriceInFinney_1000FinneyIs_1Ether, uint durationInDays){
        beneficiary = sendEtherTo;
        tokenObj = TokenInterface(adddressOfToken);
        price_token = tokenPriceInFinney_1000FinneyIs_1Ether * WEI_PER_FINNEY;
        expiryDate = now + durationInDays * 1 days;
    }
    
                                                                               
    function(){
        if (now >= expiryDate) throw;
                                                                   
        var tokens_to_send = (msg.value * BILLION) / price_token;
        uint balance = tokenObj.balanceOf(this);
        address payee = msg.sender;
        if (balance >= tokens_to_send){
            tokenObj.transfer(msg.sender, tokens_to_send);
            beneficiary.send(msg.value);    
        } else {
            tokenObj.transfer(msg.sender, balance);
            uint amountReturned = ((tokens_to_send - balance) * price_token) / BILLION;
            payee.send(amountReturned);
            beneficiary.send(msg.value - amountReturned);
        }
    }
    
    modifier afterExpiry() { if (now >= expiryDate) _ }
    
                                                                                                                  
    function checkExpiry() afterExpiry{
        uint balance = tokenObj.balanceOf(this);
        tokenObj.transfer(beneficiary, balance);
    }
}