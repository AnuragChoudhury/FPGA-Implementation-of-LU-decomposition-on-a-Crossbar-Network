#include <stdio.h>
#include <stdlib.h>

int float_to_int(float number){
    float pos_number;
    int integer_part[128];
    int fraction_part[150];
    int integer_converted_number[32];
    int return_integer;
    int actual_exp,exp=0;
    int rem,i;

    if(number<0)
        pos_number = number * -1;
    else
        pos_number = number;

    int integer_number = (int)pos_number;
    float fraction_number = pos_number - integer_number;

    int integer_bit_count = 0;
    int fraction_bit_count = 0;

    //converting the integer part to binary
    while(integer_number !=0){
        rem = integer_number % 2;
        integer_number = integer_number / 2;
        integer_part[integer_bit_count] = rem;
        integer_bit_count = integer_bit_count + 1;
    }
    integer_bit_count = integer_bit_count - 1;

    //Converting the fraction part to binary
    if(integer_bit_count >= 0){//Indicating that integer part was non zero
        for(i=0;i<23;i++){
            fraction_number = 2 * fraction_number;
            if(fraction_number >= 1){
                fraction_part[fraction_bit_count] = 1;
                fraction_bit_count = fraction_bit_count + 1;
                fraction_number = fraction_number - 1;
            }
            else{
                fraction_part[fraction_bit_count] = 0;
                fraction_bit_count = fraction_bit_count + 1;
            }
        }
        fraction_bit_count = fraction_bit_count - 1;
    }
    else{
        for(i=0;i<150;i++){
            fraction_number = 2 * fraction_number;
            if(fraction_number >= 1){
                fraction_part[fraction_bit_count] = 1;
                fraction_bit_count = fraction_bit_count + 1;
                fraction_number = fraction_number - 1;
                break; //Once the 1st '1' has been encountered, we only need to find only upto nect 23 bits
            }
            else{
                fraction_part[fraction_bit_count] = 0;
                fraction_bit_count = fraction_bit_count + 1;
            }
        }
        for(i=0;i<23;i++){
            fraction_number = 2 * fraction_number;
            if(fraction_number >= 1){
                if(fraction_bit_count == 150)
                    break;
                fraction_part[fraction_bit_count] = 1;
                fraction_bit_count = fraction_bit_count + 1;
                fraction_number = fraction_number - 1;
            }
            else{
                if(fraction_bit_count == 150)
                    break;
                fraction_part[fraction_bit_count] = 0;
                fraction_bit_count = fraction_bit_count + 1;
            }
        }
        fraction_bit_count = fraction_bit_count - 1;
    }

    //Calculating the exp and mantissa
    for(i=0;i<32;i++){
        integer_converted_number[i] = 0;
    }

    int mantissa_index = 22;
    if(integer_bit_count >= 0){
        actual_exp = integer_bit_count;
        exp = actual_exp + 127;
        if(actual_exp == 128){
            printf("Number beyond float range !!!\n");
            return 0;
        }
        for(i=integer_bit_count-1;i>=0;i--){
            if(mantissa_index<0)
                break;
            integer_converted_number[mantissa_index] = integer_part[i];
            mantissa_index = mantissa_index - 1;
        }

        for(i=0;i<23;i++){
            if(mantissa_index<0)
            break;
            integer_converted_number[mantissa_index] = fraction_part[i];
            mantissa_index = mantissa_index - 1;
        }
    }
    else{
        actual_exp = 0;

        for(i=0;i<150;i++){
            if(fraction_part[i] == 0){
                actual_exp = actual_exp - 1;
                if(actual_exp == -126){
                    exp = 0;
                    break;
                }
            }
            else{
                actual_exp = actual_exp - 1;
                exp = actual_exp + 127;
                break;
            }
        }

        for(i=i+1;i<150;i++){
            if(mantissa_index<0)
            break;
            integer_converted_number[mantissa_index] = fraction_part[i];
            mantissa_index = mantissa_index - 1;
        }
    }

    //Converting the exp to binary
    i = 23;
    while(exp!=0){
        rem = exp % 2;
        integer_converted_number[i] = rem;
        exp = exp / 2;
        i = i + 1;
    }

    //Finding 2's complement
    if(number < 0){
        int flag_found1 = 0;
        for(i=0;i<31;i++){
            if(flag_found1 == 0 && integer_converted_number[i] == 1)
                flag_found1 = 1;
            else if(flag_found1 == 1){
                if(integer_converted_number[i] == 1)
                    integer_converted_number[i] = 0;
                else
                    integer_converted_number[i] = 1;
            }
        }
    }

    //Calculating the final return integer
    return_integer = 0;
    for(i=0;i<31;i++){
        return_integer = return_integer + (integer_converted_number[i]<<i);
    }

    if(number < 0)
        return_integer = return_integer * -1;
    
    return return_integer;

}
