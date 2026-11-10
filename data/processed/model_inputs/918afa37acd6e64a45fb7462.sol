contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0x057b56736d32b86616a10f619859c6cd6f59092a);
    address public trustee = 0x065f074f1e93a215a9a05b2c92059ca44a4827eb;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}