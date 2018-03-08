pragma solidity ^0.4.15;

/**
 * @title Queue
 * @dev Data structure contract used in `Crowdsale.sol`
 * Allows buyers to line up on a first-in-first-out basis
 * See this example: http://interactivepython.org/courselib/static/pythonds/BasicDS/ImplementingaQueueinPython.html
 */

contract Queue {
	struct Person {
	    uint32 timeOver;
	    uint8 queueNumber;
	    address _address;
	}

	/* State variables */
	uint8 private size = 5;
	// YOUR CODE HERE
	address private owner;
	/*
	    Since there's no pop() function for the array in Solidity, I used two variables,
	    firstIndex and index to keep track of the order. 
	    Index is updated as (index + 1) % size, so whenever index exceeds the size of 
	    the array, it will be 0 again. 
	*/
	// indicates the first index
	uint8 private firstIndex;
	// index that the next item's going to be stored
	uint8 private index = 0;
	// number of element
	uint8 private length = 0;
    Person[] private waitingPeople;
    uint32 private timeLimit = 10 seconds;
    // for quick lookup
    mapping (address => uint8) private queueNumbers;
    mapping (address => bool) private existingUsers;
	
	/* Add events */
	// YOUR CODE HERE
	event personDeletedDueToTimeLimit(address _address);
	
	// modifier
	modifier onlyOwner() {
	    require(msg.sender == owner);
	    _;
	}
	
	modifier sizeNotMax() {
	    require(length < size);
	    _;
	}
	
	modifier isTimeUp(address _address) {
	    require(waitingPeople[queueNumbers[_address]].timeOver < now);
	    _;
	}
	
	modifier at_least_two_people_remained() {
	    require(length >= 2);
	    _;
	}
	
	modifier notEmpty() {
	    require(length > 0);
	    _;
	}

	modifier userExist(address _address) {
		require(existingUsers[_address] == true);
		_;
	}

	modifier userNotExist(address _address) {
		require(existingUsers[_address] == false);
		_;
	}

	/* Add constructor */
	// YOUR CODE HERE
	function Queue() public {
        owner = msg.sender;
	}

	/* Returns the number of people waiting in line */
	function qsize() constant public returns(uint8) {
		// YOUR CODE HERE
		return length;
	}

	/* Returns whether the queue is empty or not */
	function empty() constant public returns(bool) {
		// YOUR CODE HERE
		return length == 0;
	}
	
	/* Returns the address of the person in the front of the queue */
	function getFirst() constant public notEmpty returns(address) {
		// YOUR CODE HERE
		return waitingPeople[firstIndex]._address;
	}
	
	/* Allows `msg.sender` to check their position in the queue */
	function checkPlace() constant public notEmpty userExist(msg.sender) returns(uint8) {
		// YOUR CODE HERE
        return queueNumbers[msg.sender];
	}
	
	/* Allows anyone to expel the first person in line if their time
	 * limit is up
	 */
	function checkTime() public isTimeUp(msg.sender) notEmpty {
		// YOUR CODE HERE
		uint8 indexOfTimeUp = queueNumbers[msg.sender];
		// reallocate the index
		/*
    		ex) (i) is an index
    		2(0) => 3(1) => 4(2) => 0(3) => 1(4)
    		if 4 is the person who is time up
    		2(1) => 3(2) => 4(0) => 0(3) => 1(4)
    		meaning,
    		4(0) => 2(1) = 3(2) => 0(3) => 1(4)
    		so it reallocates the index
		*/
		uint8 i = 0;
		uint8 iteratingIndex = firstIndex;
		while (i < size) {
		    if (iteratingIndex == indexOfTimeUp) {
		        break;
		    } else {
		        uint8 qNumberOfWaitingPerson = waitingPeople[iteratingIndex].queueNumber;
		        qNumberOfWaitingPerson = (qNumberOfWaitingPerson + 1) % size;
		        uint8 qNumber = queueNumbers[waitingPeople[iteratingIndex]._address];
		        qNumber = (qNumber + 1) % size; 
		    }
		    iteratingIndex = (iteratingIndex + 1) % size;
		    i = i + 1;
		}
		queueNumbers[msg.sender] = firstIndex;
		waitingPeople[indexOfTimeUp].queueNumber = firstIndex;
	}
	
	/* Removes the first person in line; either when their time is up or when
	 * they are done with their purchase
	 */
	function dequeue() public at_least_two_people_remained {
		// YOUR CODE HERE
		Person storage deletedPerson = waitingPeople[firstIndex];
		existingUsers[deletedPerson._address] = false;
		if (deletedPerson.timeOver < now) {
			personDeletedDueToTimeLimit(deletedPerson._address);
		}
		delete waitingPeople[firstIndex];
		firstIndex = (firstIndex + 1) % size;
		length -= 1;
	}

	/* Places `addr` in the first empty position in the queue */
	function enqueue(address addr) public sizeNotMax userNotExist(addr) {
		// YOUR CODE HERE
		Person memory newPerson = Person(uint32(now + timeLimit), index, addr);
		waitingPeople.push(newPerson);
		queueNumbers[addr] = index;
		existingUsers[addr] = true;
		if (length == 0) {
		    firstIndex = index;
		}
		index = (index + 1) % size;
		length += 1;
	}
}