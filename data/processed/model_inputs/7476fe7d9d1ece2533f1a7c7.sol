contract FLescoinSale {
    address public beneficiary;
    address public coldWallet;
    uint public ethPrice;
    uint public amountRaised;
    FLescoin public tokenReward;

    uint constant public price = 5000;
    uint constant public minSaleAmount = 100000000;

    function FLescoinSale(
        address _beneficiary,
        address _coldWallet,
        uint _ethPrice,        
        FLescoin _addressOfToken
    ) {
        beneficiary = _beneficiary;
        coldWallet =  _coldWallet;
        ethPrice = _ethPrice;
        tokenReward = FLescoin(_addressOfToken);
    }

    function () payable {
        uint amount = msg.value;
        uint tokenAmount = amount * ethPrice / price / 1000000000000;
        if (tokenAmount < minSaleAmount) throw;
        amountRaised += amount;
        tokenReward.transfer(msg.sender, tokenAmount);
    }

    function WithdrawETH(uint _amount) {
        if (beneficiary != msg.sender) throw;
        coldWallet.transfer(_amount);
    }

    function WithdrawTokens(uint _amount) {
        if (beneficiary != msg.sender) throw;
        tokenReward.transfer(coldWallet, _amount);
    }

    function TransferTokens(address _to, uint _amount) {
        if (beneficiary != msg.sender) throw;
        tokenReward.transfer(_to, _amount);
    }

    function ChangeEthPrice(uint _ethPrice) {
        if (beneficiary != msg.sender) throw;
        ethPrice = _ethPrice;
    }
}