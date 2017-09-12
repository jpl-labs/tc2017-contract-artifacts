pragma solidity ^0.4.2;

contract Register {
    event Registration(address account, Charity charity, uint balance);
    enum Charity {
        Undefined,
        Animals,
        Kids,
        Disaster
    }

    mapping(bytes32 => address[]) public charityRegistrations;
    mapping(address => Charity) public accountRegistrations;
    address public owner = msg.sender;

    // Permission modifier to restrict functionality to the address which deploys this contract
    modifier onlyBy(address _account) {
        require(msg.sender == _account);
        _;
    }

    // Empty constructor so we can seed the contract with funds at deploy-time
    function Register() payable {

    }

    // Performs the registration function by assigning a charity to the address and adding the address to a group associated to the charity; pays the initial 1000 ether
    function register(address account, Charity charity) onlyBy(owner) {
        require(accountRegistrations[account] == Charity.Undefined && account.balance == 0 ether);

        charityRegistrations[sha3(charity)].push(account);

        accountRegistrations[account] = charity;

        account.transfer(1000 ether);

        Registration(account, charity, this.balance);
    }

    // Getter to expose all addresses registered with a given charity
    function getAddressesByCharity(Charity charity) constant returns (address[] addresses) {
        return charityRegistrations[sha3(charity)];
    }

    // Getter to expose the charity registered with a given account
    function getCharityByAddress(address addr) constant returns (Charity charity) {
        return accountRegistrations[addr];
    }
}
