contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0x35a051a0010aba705c9008d7a7eff6fb88f6ea7b);
    address public trustee = 0x42b8a09e46e6e367ed0135d3cd7fbdce777e0873;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}