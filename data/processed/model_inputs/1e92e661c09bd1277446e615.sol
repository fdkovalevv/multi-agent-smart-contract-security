contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0x440c59b325d2997a134c2c7c60a8c61611212bad);
    address public trustee = 0xfdf97eaa34a883647fac329926b1747e9ef601c6;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}