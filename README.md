+++++++++++++
Instructions:
+++++++++++++

        1. Run the following command:
                time mix run persquare.ex <value_of_n> <value_of_k>

           Output:
                [sorted list of first number of perfect square sequences]

                real:<real time>
                user:<user time>
                sys:<sys time>
        
           For examples refer sample outputs below

        2. To see the code documentation, run "mix docs" in persquare directory. Open doc/index.html in web browser.

++++++++++++++++++++++++++++++
Analysis on size of work unit:
++++++++++++++++++++++++++++++

        In a single request, the master process sends a sequence of length k to a worker process (there are many such processes). So the size of work unit is k. The worker checks if the given sequence is a perfect square sequence and returns true or false accordingly. If there are more sequences to be processed, the master responds back with a sequence of numbers. This goes on for all the processes until all the N sequences are processed. We found this design to be the best performing one. The other design we came up with was to compute the square of each number from 1 to N parallely (1 worker sqaures 1 number) and then sum up N sequences of these numbers of length k parallely. However, this approach has the following limitations:
                - Extra memory for storing the squares of each number from 1 to N.
                - Extra time to sort the list of squared numbers.
                - Master needs to wait till all the sqaures are computed by workers.

+++++++++++++++++++++++++++++
Result of running the program for:
+++++++++++++++++++++++++++++

        mix run persquare.ex 1000000 4
        []

+++++++++++++++
Sample Outputs:
+++++++++++++++
        
        1. time mix run persquare.ex 1000000 4
        []

        real	0m3.402s
        user	0m7.135s
        sys	0m2.305s

        No. of cores used = (user + sys) / real = 2.77

        2. 
        mix run persquare.ex 1000000 24
        [1, 9, 20, 25, 44, 76, 121, 197, 304, 353, 540, 856, 1301, 2053, 3112, 3597,
        5448, 8576, 12981, 20425, 30908, 35709, 54032, 84996, 128601, 202289, 306060,
        353585, 534964, 841476]

        real	0m3.617s
        user	0m11.513s
        sys	0m0.716s

++++++++++++++++++++++
Largest problem solved
++++++++++++++++++++++

        time mix run persquare.ex 5000000 5329
        [17, 175, 349, 1757, 2023, 2555, 4469, 4843, 5257, 6373, 11725, 12467, 13289,
        17027, 20065, 36763, 42833, 56489, 95935, 115657, 194543, 293149, 588965]

        real	17m50.590s
        user	68m36.122s
        sys	0m6.723s

+++++++++++++++++++++++
Result of running following cases:
+++++++++++++++++++++++
        
            No. of processes    |     N     |     k     |no. of cores used
        
                100000          |  1000000  |     4     |       2.75       
       
                10000           |  1000000  |     4     |       2.6       
       
                1000            |  1000000  |     4     |       2.77       
        
                100000          |  1000000  |     24    |       2.83       
        
                10000           |  1000000  |     24    |       3.29       
        
                1000            |  1000000  |     24    |       3.38       
        
                100000          |  1000000  |     409   |       3.09       
        
                10000           |  1000000  |     409   |       3.8       
        
                1000            |  1000000  |     409   |       3.83       
        
                10000           |  1000000  |     5329  |       3.8       
        
                1000            |  1000000  |     5329  |       3.8       
        
                10000           |  1000000  |     9600  |       3.7       
        
                1000            |  1000000  |     9600  |       3.83      
        
                1000            |  10000000 |     4     |       2.77
        
                10000           |  10000000 |     4     |       2.76      
        
                1000            |  10000000 |     24    |       3.45
        
                10000           |  10000000 |     24    |       3.26   


        Based on the above results, the following can be inferenced:

        1. The best performance is obtained when we create 1000 processes. So in our code, when N > 1000, we create 1000 processes and when N < 1000, we create N processes.

        2. When number of processes is in the order of 10000 or more, the performance reduces. This is because the overhead of maintaining those many processes costs more than finding the perfect sqauare sequences.

        3. As k increases, the performance also increases. This is because when the length of sequences is high, the cost of maintaining the processes is negligible.
