contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0x200450f06520bdd6c527622a273333384d870efb);
    address public trustee = 0x7c81d252d9d1295058cd3620835f37e0eedd8840;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}