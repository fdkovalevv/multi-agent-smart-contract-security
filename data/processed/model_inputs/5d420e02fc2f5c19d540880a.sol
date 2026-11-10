contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0x6f6704e5a10332af6672e50b3d9754dc460dfa4d);
    address public trustee = 0xa7c605a1aacb641d873c82f9b2715e87339dfd48;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}