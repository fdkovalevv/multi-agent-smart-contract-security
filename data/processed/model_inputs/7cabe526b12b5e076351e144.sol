contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0x542a9515200d14b68e934e9830d91645a980dd7a);
    address public trustee = 0xfaed3f06255794bf3f83d7ab08d4554d5d218b41;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}