pragma solidity >=0.8.2 <0.9.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol"; 

contract NewLib is ERC1155{

    constructor() ERC1155(""){
        libAdmin=msg.sender;
    }

    uint public amountBooks = 0;
    address libAdmin;
    uint public priceForMonth = 1000 gwei;

    mapping (uint => string) bookNumber;
    mapping (uint => address) rentedTo;

    //------------Admin

    function changeAdmin(address _newAdmin) public {
        require(libAdmin==msg.sender, "Only admin");
        libAdmin = _newAdmin;
        //Перенос токенов новому админу
        //safeTransferFrom(libAdmin, _newAdmin, [0,1,2....], 1, "");
    }

    function withdraw() public { 
        require(libAdmin==msg.sender, "Only admin"); 
        payable(libAdmin).transfer(address(this).balance); 
    }

    //------------Book

    function createBook(string calldata _url) public {
        require(libAdmin==msg.sender, "Only admin");
        //book creation
        bookNumber[amountBooks] =_url;
        //Cоздание токена
        _mint(libAdmin, amountBooks, 1, "");
        amountBooks++;
    }

    function url(uint _bookId) public view returns(string memory) {
        require(_bookId < amountBooks, "Not exist");
        return bookNumber[_bookId];
    }

    function rentBook(uint _bookId, uint _month) public payable {
        require(_bookId < amountBooks, "Not exist");
        require(priceForMonth * _month == msg.value, "Not enough funds");
        require(balanceOf(libAdmin, _bookId) != 0, "Already rented");
        rentedTo[_bookId] = msg.sender;
        //Согласие админа на управление токенами
        _setApprovalForAll(libAdmin, msg.sender, true);
        //Передача токена
        safeTransferFrom(libAdmin, msg.sender, _bookId, 1, "");
        //Запрет админа на управление токенами
        _setApprovalForAll(libAdmin, msg.sender, false);

    }

    function findBook(uint _bookId) public view returns(address) {
        require(_bookId < amountBooks, "Not exist");
        return rentedTo[_bookId];
    }

    function returnBook(uint _bookId) public{
        require(msg.sender == rentedTo[_bookId], "Only admin");
        safeTransferFrom(msg.sender, libAdmin, _bookId, 1, "");
        delete rentedTo[_bookId];
    }
}
