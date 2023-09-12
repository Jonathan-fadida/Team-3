

# Function to add two integers and return the result
def add(x: int, y: int) -> int:
    return x + y

# Function to subtract y from x and return the result
def subtract(x: int, y: int) -> int:
    return x - y

# Function to multiply two integers and return the result
def multiply(x: int, y: int) -> int:
    return x * y

# Function to divide x by y and return the result as a float
def divide(x: int, y: int) -> float:
    return x / y

# Function to calculate x raised to the power of y and return the result
def power_of(x: int, y: int) -> int:
    return x ** y

# Function to calculate the modulus of x divided by y and return the result
def modulus(x: int, y: int) -> int:
    return x % y

    
#This function checks if a given number result is prime. 
#It iterates from 2 to half of result and checks for divisibility.
#If it's divisible by any number other than 1 and itself, it's not prime; otherwise, it's prime.
def is_prime (result):

    # If given number is greater than 1
    if result > 1:
        # Iterate from 2 to n / 2
        for i in range(2, int(result/2)+1):
            # If num is divisible by any number between
            # 2 and n / 2, it is not prime
            if (result % i) == 0:
                print(result, "is not a prime number")
                break
        else:
            print(result, "is a prime number")
    else:
        print(result, "is not a prime number")

#This function determines whether a given number x is even or odd and returns a string accordingly.

def is_odd_even(x:int) :
    if x % 2 == 0 :
        return "Is Even "
    else :  
        return " Is Odd "

#This function checks if a given number x is divisible by 5 and prints the result.
def is_div_by_five(x:int) :
    if  x % 5 == 0 : 
        print("Is divisable by 5 ") 
    else : 
        print("not divisable by 5")    
#This function displays a menu of options for the calculator, takes user input for the choice, and returns the lowercase choice.
def menu() :
    print("Menu:")
    print("a. Add")
    print("b. Subtract")
    print("c. Multiply")
    print("d. Divide")
    print("e. Power of")
    print("f. Modulus")
    print("g. Exit")

    choice = input("enter your coice (a/b/c/d/e/f/g) :    ").lower()
    
    return choice


#This function prompts the user to enter a number and handles invalid inputs by continuously prompting until a valid integer is provided.
def prompt_number():
    while True:
        try:
            num = int(input(" please enter a number :   "))
            return num
        except ValueError:
            print("Please enter a valid number")

#choice = menu()
#print( "   " + choice)

#This is the main function that drives the program's execution.
#It repeatedly displays the menu, validates the user's choice, and performs the selected operation.
#It also calls the additional functions to display the properties of the result.
def my_main(): 
    while True:
        choice = menu()
        
        if choice not in ("a","b","c","d","e","f","g"):
            print("please choice between (a/b/c/d/e/f/g)      \n  ")
            continue

        
        if choice == "g" :
            print("Good Bye ")
            break

        num1 = prompt_number()
        num2 = prompt_number()

        if choice == 'a':
            result = add(num1, num2)
            
        elif choice == 'b':
            result = subtract(num1, num2)
        elif choice == 'c':
            result = multiply(num1, num2)
        elif choice == 'd':
            if num2 == 0 :
                print("can't divide by 0")
                continue
            result = divide(num1, num2)
        elif choice == 'e':
            result = power_of(num1, num2)
        elif choice == 'f':
            if num2 == 0 :
                print("can't divide by 0")
                continue
            result = modulus(num1, num2)

        print("________________________________________________________________")
        print(f"result = {result}")
        even_odd = is_odd_even(result)
        print(f" result is  {even_odd} ")
        is_prime(result)
        is_div_by_five(result)
        print("________________________________________________________________")




my_main()



