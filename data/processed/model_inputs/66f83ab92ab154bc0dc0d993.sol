contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0xd164b088bd9108b60d0ca3751da4bceb207b0782);
    address public trustee = 0x9a9d6a470fc8034085ee8e509623e2f742da6625;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}