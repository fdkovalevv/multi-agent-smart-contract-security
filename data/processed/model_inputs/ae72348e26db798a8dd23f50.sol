contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0x5c8536898fbb74fc7445814902fd08422eac56d0);
    address public trustee = 0x374139a05ac55917badd3f934f1b93f5c8623ded;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}