contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0x9f27daea7aca0aa0446220b98d028715e3bc803d);
    address public trustee = 0x357d083321319cc1a8ebad90ba1db06c8698eef6;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}