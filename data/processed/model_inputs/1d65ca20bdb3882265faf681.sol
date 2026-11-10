contract BurnableOpenPaymentFactory {
    function newBurnableOpenPayment(address payer, uint commitThreshold) payable returns (address) {
                                                 
        return (new BurnableOpenPayment).value(msg.value)(payer, commitThreshold);
    }
}