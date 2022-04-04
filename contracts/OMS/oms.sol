pragma solidity >=0.4.4 <0.9.0; // 0.8.6
pragma experimental ABIEncoderV2;


contract OMS_COVID {

    //address OMS owner of the contract
    address public OMS;

    constructor() public {
        OMS = msg.sender;        
    }

    mapping(address => bool) public Valid_clinics;
    address[] public availableClinics;
    mapping(address => address) clinicAdress;

    address[] requestsClinis;

    event newValidClinic(address);
    event newContract(address, address);
    event newRequest(address);


    modifier isOwner(address _address) {
        require(_address == OMS , "You are not the owner of the contract");
        _;
    }

    function requestContractClinic() public {
        requestsClinis.push(msg.sender);
        emit newRequest(msg.sender);
    }

    function getRquestClinic() public view isOwner(msg.sender) returns(address[] memory) {
        return requestsClinis;
    }

    function ValidateClinic(address _address) public isOwner(msg.sender){
        Valid_clinics[_address] = true;
        emit newValidClinic(_address);
    } 

    function FactoryClinic() public {
        require(Valid_clinics[msg.sender] == true," you do not have permissions");

        address contractClinic = address(new Clinic(msg.sender));
        availableClinics.push(contractClinic);
        clinicAdress[msg.sender] = contractClinic;
        emit newContract(contractClinic, msg.sender);

    }

}

//contract to manage a clinic

contract Clinic {

    address public addressClinic;
    address public addressContract;

    constructor (address _address) public {
        addressClinic = _address;
        addressContract = address(this);
    }

    struct resultsCovid {
        bool hasCovid;
        string IPFScode;
    }

    mapping(bytes32 => resultsCovid) covidResults;


    //events
    event newResult(string ,bool);


    modifier isClinicOwner(address _address) {
        require(_address == addressClinic, "you are not the owner");
        _;
    }

    function covidResultsTest(string memory _idPerson, bool _resultCOVID, string memory _codeIPFS ) public isClinicOwner(msg.sender) { 

        bytes32 has_idPerson = keccak256(abi.encodePacked(_idPerson));
        covidResults[has_idPerson] = resultsCovid(_resultCOVID,_codeIPFS);

        emit newResult(_codeIPFS,_resultCOVID);
    }

    function getResultsCovid(string memory _idPerson ) public view returns (string memory, string _IPFScode) {

        bytes32 has_idPerson = keccak256(abi.encodePacked(_idPerson));

        string memory result;

        if(covidResults[has_idPerson].hasCovid == true){
            result = "Positivo";
        } else { 
            result = "Negativo";
        }

        return (result, covidResults[has_idPerson].IPFScode);
    }
}