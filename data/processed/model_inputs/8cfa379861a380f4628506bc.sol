contract WithdrawDAO {
    DAO constant public mainDAO = DAO(0x0101f3be8ebb4bbd39a2e3b9a3639d4259832fd9);
    address public trustee = 0x46664c1e2ddd896a3e0c2b3d502842f261b9e62f;

    function withdraw(){
        uint balance = mainDAO.balanceOf(msg.sender);

        if (!mainDAO.transferFrom(msg.sender, this, balance) || !msg.sender.send(balance))
            throw;
    }

    function trusteeWithdraw() {
        trustee.send((this.balance + mainDAO.balanceOf(this)) - mainDAO.totalSupply());
    }
}