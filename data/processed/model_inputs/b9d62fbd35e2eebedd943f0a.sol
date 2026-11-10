contract RipplePayMain {

mapping(string => address) currencies;

function newCurrency(string currencyName, string currencySymbol, uint8 decimalUnits){
currencies[currencySymbol] = new IOU(currencyName, currencySymbol, decimalUnits);
}

function issueIOU(string _currency, uint256 _amount, address _to){
                                                                                                              
    IOU(currencies[_currency]).transfer(msg.sender, _to, _amount);

}

}