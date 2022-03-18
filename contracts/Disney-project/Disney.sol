pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;

import "../ERC20/ERC20.sol";

contract Disney {

    // instance of the contract
    ChrisCoin private token;

    //address of the owner
    address payable public owner;

    //constructor
    constructor () public {
        token = new ChrisCoin(10000);
        owner = msg.sender;
    }

    // DTO of the disney client
    struct client {
        uint tokens_bought;
        string [] attractions_enjoyed;
    }

    // mapping for client register
    mapping (address => client) public Clients;


    // function to set the price of the token 
    function TokenPrice (uint _numTokens) internal pure returns (uint) {
        return _numTokens*(1 ether);
    }

    // function to buy tokens 
    function BuyTokens(uint _numTokens) public payable {

        uint cost = TokenPrice(_numTokens);
        require(msg.value >= cost , "buy less tokens or add more ether");

        // calculating if I have ether left over from what they sent and returning it
        uint returnValue = msg.value - cost;
        msg.sender.transfer(returnValue);

        uint Balance = balanceOf();
        require(_numTokens <= Balance, "buy less tokens");

        token.transfer(msg.sender, _numTokens);

        Clients[msg.sender].tokens_bought += _numTokens;

    }

    // balance of the tokens of the smart contract
    function balanceOf() public view returns(uint) {
        return token.balanceOf(address(this));
    } 

    // get tokens of one adreess
    function getTokens() public view returns(uint) {
        return token.balanceOf(msg.sender);
    }

    //add more tokens
    function addTokens(uint _numTokens) public isOwner(msg.sender){
        token.increaseTotalSupply(_numTokens);
    }

    // modifier 
    modifier isOwner(address _address){
        require(_address == owner, "You are not the owner of this contract");
        _;
    }

    // Events
    event enjoy_attraction(string, address);
    event new_attraction(string, uint);
    event down_attraction(string);


    // declaration of variables
    struct attraction {
        string name;
        uint price;
        bool state;
    }
    mapping (string => attraction) public Attrations;
    string[] AttrationsName;
    mapping(address => string[]) historyAttractions;


    // create new attractions
    function newAttraction(string memory _name, uint _price) public isOwner(msg.sender) {
        Attrations[_name] = attraction(_name, _price, true);
        AttrationsName.push(_name);
        //emit event
        emit new_attraction(_name, _price);
    }

    function DownAttraction(string memory _name) public isOwner(msg.sender) {
        Attrations[_name].state = false;
        emit down_attraction(_name);
    }

    function AttractionsAvailable() public view returns(string [] memory) {
        return AttrationsName;
    }

    function ConsumeAttraction (string memory _name) public {
        uint price_attraction = Attrations[_name].price;
        require(Attrations[_name].state == true, "the attraction is unavailable");
        //check tokens of the client
        require( price_attraction < getTokens(), "you don't have enough tokens");
        // this is because transfer send the address of the contract and not of the client
        token.transfer_disney(msg.sender, address(this), price_attraction);
        historyAttractions[msg.sender].push(_name);
        emit enjoy_attraction(_name, msg.sender);
    }

    function getHistoryClient() view public returns(string [] memory) {
        return historyAttractions[msg.sender];
    }

    function returnTokens(uint _numTokens) public payable {

        require(_numTokens > 0, "error ");
        //check the user tokens with the param
        require(_numTokens <= getTokens(), "you don't have this amount of tokens");
        // return tokens to the smart contract
        token.transfer_disney(msg.sender, address(this), _numTokens);
        // return ethers to client for tokens
        msg.sender.transfer(TokenPrice(_numTokens));
    }

}