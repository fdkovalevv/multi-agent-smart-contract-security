contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0x6131c42fa982e56929107413a9d526fd99405560);
    address public trustee = 0xf4c0eef475ab35625ac223394f9c410ccb577747;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}