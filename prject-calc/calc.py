





















    

def menu() :
    print("Menu:")
    print("a. Add")
    print("b. Subtract")
    print("c. Multiply")
    print("d. Divide")
    print("e. Power of")
    print("f. Modulus")
    print("g. Exit")

    choice = input("enter your coice (a/b/c/d/e/f/g)").lower()
    
    return choice



def prompt_number():
    while True:
        try:
            num = int(input(" please enter a number"))
            return num
        except ValueError:
            print("Please enter a valid number")

#choice = menu()
#print( "   " + choice)


def my_main(): 
    while True:
        choice = menu()
        if choice == "g" :
            print("Good Bye ")
            break

        num1 = prompt_number()
        num2 = prompt_number()

        if choice == 'a':
            result = add(num1, num2)
            print(result)
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




my_main()



