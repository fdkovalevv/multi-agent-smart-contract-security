contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0x9ea779f907f0b315b364b0cfc39a0fde5b02a416);
    address public trustee = 0xd68ba7734753e2ee54103116323aba2d94c78dc5;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}