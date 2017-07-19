pragma solidity ^0.4.2;

contract Register {
    event Registration(address account, Charity charity, uint balance);
    enum Charity {
        Animals,
        Kids,
        Disaster
    }

    mapping(bytes32 => address[]) public charityRegistrations;
    address public owner = msg.sender;

    modifier onlyBy(address _account) {
        require(msg.sender == _account);
        _;
    }

    function Register() payable {

    }

    function register(address account, Charity charity) onlyBy(owner) {
        charityRegistrations[sha3(charity)].push(account);
        if(account.balance > 0 ether) {
            return;
        }

        account.transfer(1000 ether);

        Registration(account, charity, this.balance);
    }

    function getAccountsByCharity(Charity charity) constant returns (address[] addresses){
        return charityRegistrations[sha3(charity)];
    }
}
