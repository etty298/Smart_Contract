pragma solidity >=0.8.2 <0.9.0;


contract Library{

    constructor(){
        libAdmin=msg.sender;
    }

    uint amountBooks = 0;
    address libAdmin;
    uint public priceForMonth = 1000 gwei;

    struct Book {
        string name;
        string picture;
        bool availability;
    }

    mapping (uint => Book) bookNumber;
    mapping (uint => address) rentedTo;

    //------------Admin

    function changeAdmin(address _newAdmin) public {
        require(libAdmin==msg.sender, "Only admin");
        libAdmin = _newAdmin;
    }

    //------------Book

    function createBook(string calldata _name, string calldata _image) public returns(uint){
        require(libAdmin==msg.sender, "Only admin");
        //book creation
        bookNumber[amountBooks] = Book(_name, _image, true);
        amountBooks++;

    }

    function bookInfo(uint _bookID) public view returns ( Book memory){
        return bookNumber[_bookID];
    }

    function rentBook(uint _bookId, uint _month) public payable {
        require(_bookId < amountBooks, "Not exist");
        require(priceForMonth * _month == msg.value, "Not enough funds");
        //require(rentedTo[_bookId]==0x0000000000000000000000000000000000000000, "Already rented");
        require(bookNumber[_bookId].availability, "Already rented");
        rentedTo[_bookId] = msg.sender;
        bookNumber[_bookId].availability = false;
    }

    function findBook(uint _bookId) public view returns(address) {
        require(_bookId < amountBooks, "Not exist");
        return rentedTo[_bookId];
    }

    function returnBook(uint _bookId) public{
        require(msg.sender == libAdmin || msg.sender == rentedTo[_bookId], "Only admin");
        bookNumber[_bookId].availability == true;
        delete rentedTo[_bookId];
    }

    function withdraw() public { 
        require(libAdmin==msg.sender, "Only admin"); 
        payable(libAdmin).transfer(address(this).balance); 
    }


}
