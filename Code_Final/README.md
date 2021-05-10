## 1. Compilation without make
    * bison -d bison.y
    * flex flex.l
    * gcc lex.yy.c bison.tab.c -lfl
    * ./a.out <xyz.prog  
  * This will print the asm code on the terminal. Can run the same code in MARS simulator.
 
## 2. Language specifications
    * Only integer datatype
    * Function not compulsory, can execute only main function. 
    * Only '<' comparison operator allowed
    * All function definitions at the start, followed by the main function. Program code must start from the first line.
    
        def func1(a){
        }
        
        def func2(b){
        }
        
        def main(){
        }
        
    * No global variable or arrays. Arrays supported only inside main
      
        def main(){
          startdecl 
            decl a[10]
          enddecl
         ...
         }
    
    * Function calls with single parameter passing only and compulsory return value. Value stored in register $t0 will be returned. $t0 adjusted accordingly.
    
        def func(q){
          a = q
          a = a+1
          return
        }
        
    
## 3. Language features
    
    * Recursive function calls
        
        def func ( a ) {
          
           if ( a < 2){
              b = a       //need this statement so that value of a is returned
              return
           }
           ...
           c = func ( d )
           ...
        }
        
     
    * Supports if-else conditionals. Grammar is left factored to remove shift-reduce ambiguilty.
        
        //if-else
        if ( a < b ) {
          c = c+1
        }
        else{
          ...
        }
        
        //only if
        if(b<3){
          ...
        }
        
        
    * Support for loop, while loop, nested for, nested while.
        
        
        c = 0 
        
        //loop
        while ( c < 100 ) {
          ...
          c = c + 1
        }
        
        //nested loop
        for ( int i = 0 ; i < 4 ; i++ ) {
          ...
          d = 0
          while( d < 10 ){
            ...
          }
          
        }


     * Input / Output.
               
        x = input()
        print(x)
        
     * Arrays.
                
        b = a[i]
        a[j] = d
        b[i] = a[j]
        
## 4. Team and resources
     
      * Ajinkya Pawar - 18110013
      * Pranshu Kumar Gond - 18110124
      * Sagar Bisen - 18110149
      * Shruti Katpara - 
      * Anupam Kumar -18110022
   * No repo or website was referred to :)
 
     
      
    
          
        
         

  
