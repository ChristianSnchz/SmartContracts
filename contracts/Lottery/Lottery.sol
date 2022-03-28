pragma solidity >=0.4.4 <0.7.0; // 0.6.6
pragma experimental ABIEncoderV2;

import "../ERC20/ERC20.sol";


contract Lotery {

    //instance of token
    ChrisCoin private token;

    //address owner
    address public owner;
    address public smartcontract;

    // number of tokens to create
    uint public numberBeginTokens = 10000;

    event buyTokensEvent(uint, address);

    constructor() public {
        token = new ChrisCoin(numberBeginTokens);
        owner = msg.sender;
        smartcontract = address(this);
    }


    modifier isOwner(address _direction){
        require(_direction == owner, "error-msg: you need to be owner");
        _;
    }

    // TOKENS
    function tokensPrice(uint _numTokens) internal pure returns(uint){
        return _numTokens*(1 ether);
    }


    //generate more tokens if you are the owner of the contract
    function generateMoreTokens(uint _numTokens) public isOwner(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }

    function buyTokens(uint _numTokens) public payable {

        uint cost = tokensPrice(_numTokens);

        require(msg.value >= cost, "you need to send more ethers");

        uint returnValue = msg.value - cost;

        msg.sender.transfer(returnValue);

        uint balance = availableTokens();

        require(_numTokens <= balance, "there are not a that amount of tokens avaible");        

        token.transfer(msg.sender, _numTokens);

        emit buyTokensEvent(_numTokens, msg.sender);
    }

    //tokens balances of the contract
    function availableTokens() public view returns(uint) {
        return token.balanceOf(smartcontract);
    }

    //get tokens for the winner
    function getAward() public view returns (uint) {
        return token.balanceOf(owner);
    }

    //get Tokens for any person
    function getTokens() public view returns(uint) {
        return token.balanceOf(msg.sender);
    }
    //end region Tokens

    // LOTTERY LOGIC

    // price of the ticket
    uint public ticketPrice = 5;

    // 
    mapping(address => uint[]) idPerson_Ticket;
    mapping(uint => address) ADN_ticket;

    uint randomNonce = 0;
    uint [] tickets_bought;
    event ticket_bought(uint, address);
    event ticket_winner(uint);

    event returned_tokens (uint, address);



    //Buy tickets
    function buyTicket(uint _numberOfTickets) public {

        uint priceTickets = _numberOfTickets*ticketPrice;

        require(priceTickets <= getTokens(), "you need to buy more tokens");

        token.transfer_disney(msg.sender, owner, priceTickets);

        for (uint i= 0; i < _numberOfTickets; i++ ) {
            uint random = uint(keccak256(abi.encodePacked(now, msg.sender, randomNonce))) % 10000;
            randomNonce++;

            idPerson_Ticket[msg.sender].push(random);
            tickets_bought.push(random);
            ADN_ticket[random] = msg.sender;

            emit ticket_bought(random, msg.sender);
        }
    }

    // get my tickets
    function myTickets() public view returns(uint [] memory){
        return idPerson_Ticket[msg.sender];
    }

    // generate Winner 
    function GenerateWinner() public isOwner(msg.sender) {

        require(tickets_bought.length > 0, "there is not tickets bought");

        uint long = tickets_bought.length;
        uint index = uint(uint(keccak256(abi.encodePacked(now))) % long);
        uint winner = tickets_bought[index];

        emit ticket_winner(winner);

        address winner_address = ADN_ticket[winner];
        token.transfer_disney(msg.sender, winner_address, getAward());
    }


    // Return tokens to ethers
    function returnTokens(uint _numTokens) public payable {

        require(_numTokens > 0, "error");
        require(_numTokens <= getTokens(), "error");

        token.transfer_disney(msg.sender, address(this), _numTokens);

        msg.sender.transfer(tokensPrice(_numTokens));
        emit returned_tokens(_numTokens, msg.sender);

    }

}