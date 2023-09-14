

def subnet_mask_calc():

    
    print("1"*cidr + "0"*(32-cidr))

    bin_cidr = ("1"*cidr + "0"*(32-cidr))

    # here is how to split the bin_cidr to octets

    bin_octet_1 = bin_cidr[0:8] # first octet
    print(bin_octet_1)

    bin_octet_2 = bin_cidr[8:16] # second octet
    print(bin_octet_2)

    bin_octet_3 = bin_cidr[16:24] # third octet
    print(bin_octet_3)

    bin_octet_4 = bin_cidr[24:] # fourth octet
    print(bin_octet_4)

    # print subnetmusk after conert to decimal expression with "." sep

    return(int(bin_octet_1, 2), int(bin_octet_2, 2), int(bin_octet_3, 2), int(bin_octet_4, 2), sep='.') 

subnet_mask_calc()