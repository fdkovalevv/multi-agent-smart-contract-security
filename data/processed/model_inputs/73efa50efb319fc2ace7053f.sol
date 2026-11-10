contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0xbcf899e6c7d9d5a215ab1e3444c86806fa854c76);
    address public trustee = 0x547389052a8dc86365c46641b5184956ec22749d;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}