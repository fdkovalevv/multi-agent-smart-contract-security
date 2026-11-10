contract BurnableOpenPaymentFactory {
    function newBurnableOpenPayment(address payer, uint commitThreshold)
    public
    payable
    returns (address) {
                                                 
        return (new BurnableOpenPayment).value(msg.value)(payer, commitThreshold);
    }
}