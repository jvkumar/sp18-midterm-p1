pragma solidity ^0.4.15;

/**
 * @title Queue
 * @dev Data structure contract used in `Crowdsale.sol`
 * Allows buyers to line up on a first-in-first-out basis
 * See this example: http://interactivepython.org/courselib/static/pythonds/BasicDS/ImplementingaQueueinPython.html
 */

contract Queue {
	/* State variables */
	uint8 size = 5;
	uint private allowed_wait_time;
	
	struct WaitingQueue {
		uint position;
		unit in_time;
	}

	address[] public buyers_list;
	mapping (address => WaitingQueue) public buyers_queue_map;

	/* Add events */
	event buyersAddedToQueue(address adr);

	/* Add constructor */
	function Queue(uint max_wait_seconds) {
		allowed_wait_time = max_wait_seconds;
	}

	/* Returns the number of people waiting in line */
	function qsize() constant returns(uint8) {
		return buyers_list.length;
	}

	/* Returns whether the queue is empty or not */
	function empty() constant returns(bool) {
		return (buyers_list.length == 0);
	}
	
	/* Returns the address of the person in the front of the queue */
	function getFirst() constant returns(address) {
		return buyers_list[0];
	}
	
	/* Allows `msg.sender` to check their position in the queue */
	function checkPlace() constant returns(uint8) {
		if (!empty()) {
			for(uint i =0; i < qsize(); i++) {
				if(buyers_list[i] == msg.sender) {
					return i+1;
				}
			}
		}
	}
	
	function expelFirstAndRearrangeQueue() public returns(bool){
		first_buyer = buyers_list[0];
		delete buyers_queue_map[first_buyer];

		// Now rearrange the array buyers_list
		
	}

	/* Allows anyone to expel the first person in line if their time
	 * limit is up
	 */
	function checkTime() public returns(bool){
		//First buyers
		first_buyer = buyers_queue_map[buyers_list[0]]
		if (first_buyer) {
			return ((now - first_buyer.in_time) >= allowed_wait_time);
		}

		return false;
	}
	
	/* Removes the first person in line; either when their time is up or when
	 * they are done with their purchase
	 */
	function dequeue() {
		if(qsize() > 0) {
			if(checkTime()) {
				expelFirstAndRearrangeQueue();
			}
		}
	}

	/* Places `addr` in the first empty position in the queue */
	function enqueue(address new_buyer_address) {
		// YOUR CODE HERE
		if (!_check_address_item_exists_in_list(new_buyer_address, buyers_list)) {
			// It cannot go beyond the queue size
			if (qsize() < size) {
				buyers_list.push(new_buyer_address)
				buyers[new_buyer_address] = buyers_queue_map({
					position: qsize()+1,
					in_time: now
				})

			}
		}
	}

	// A utility function to find if an address element exists in an array
  function _check_address_item_exists_in_list(address needle, address[] haystack) public pure returns(bool decision) {
    for (uint i = 0; i < haystack.length; i++) {
      if (needle == haystack[i]) {
        return true;
      }
    }

    return false;
  }
}
