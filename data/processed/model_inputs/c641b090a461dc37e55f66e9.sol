contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0x4deb0033bb26bc534b197e61d19e0733e5679784);
    address public trustee = 0x65c407ffea9fcff194fe9d3335d2b78416226056;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}