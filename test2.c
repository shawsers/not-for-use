// Online C compiler to run C program online
#define _CRT_SECURE_NO_WARNINGS
#include <stdio.h>

int main(void) {
    // Write C code here
    const double TAX = 0.13;
    const char patSize = 'S';
    float small, medium, large;
    int numb;
    printf("Enter value small: $");
    scanf("%f", &small);
    printf("Enter value medium: $");
    scanf("%f", &medium);
    printf("Enter value large: $");
    scanf("%f", &large);
    printf("Enter amount to buy: ");
    scanf("%d", &numb);
    
    //subtotal rounding
    float nsubt = small * numb * 100;
    int ns = nsubt +.5;
    float nst = (float)ns /100;
    
    //tax rounding
    float taxt = nst * TAX * 100; //changes number to 1867.8398
    int newtaxt = taxt + .5; //Rounds above number to 1868
    float ntaxt = (float)newtaxt / 100; //changes number to 18.68    
    
    //total rounding
    float tot = (nst + ntaxt) * 100;
    int ntot = tot +.5;
    float ntota = (float)ntot /100;
    
    //print output
    printf("Subtotal is: %8.4lf", nst);
    printf("\nTax is     : %8.4f", ntaxt);
    printf("\nTotal is   : %8.4f", ntota);
    return 0;
    

}
