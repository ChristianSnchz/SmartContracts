// SPDX-License-Identifier: MIT
pragma solidity >=0.4.4 <0.7.0;
pragma experimental ABIEncoderV2;


/** 
    Mock Students 

    Student        ID         notes
    Christian   7775634       9
    Peter        8734345       5
    Bruce        7543884.      7
**/

// 0x0Fbfb3FAa9D789E3a07616676C799a274B3FCC97 rinkeby TEST address


contract notes {

    // addres from teacher who deploy the contract
    address public teacher;

    constructor() public {
        teacher = msg.sender;
    }

    //mapping for join the hash of one student with his note from test
    mapping (bytes32 => uint) Notes;

    // array from studentds who review his note
    string [] reviews;

    //events
    event student_evaluated(bytes32);
    event student_review(string);

      //modifier 
    modifier OnlyTeacher(address _direction) {
        require(_direction == teacher, "you do not have permissions");
        _;
    }

    function Evaluate(string memory _idStudent, uint _note) public OnlyTeacher(msg.sender) {
        // hash from student
        bytes32 hash_student = keccak256(abi.encodePacked(_idStudent));

        Notes[hash_student] = _note;
        emit student_evaluated(hash_student);        
    }

  
    function GetNotes(string memory _idStudent) public view returns(uint){
        bytes32 hash_student = keccak256(abi.encodePacked(_idStudent));
        return Notes[hash_student];
    }

    function Review(string memory _idStudent) public {
        reviews.push(_idStudent);
        emit student_review(_idStudent);
    }

    function GetReviews() public OnlyTeacher(msg.sender) view returns(string [] memory) {
        return reviews;
    }

}