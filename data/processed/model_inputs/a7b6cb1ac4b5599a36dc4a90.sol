contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0xd9aef3a1e38a39c16b31d1ace71bca8ef58d315b);
    address public trustee = 0x2b15c5211bda6a867c582080536f6c61766aa5af;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}