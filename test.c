// Online C compiler to run C program online
#include <stdio.h>

int main(void) {
    const double TAX = 0.13;
    const char patSize = 'S', salSize = 'M', tomSize = 'L';
    float small, medium, large;
    int numb, numbp, numbt, numbs;
    printf("Enter value small: $");
    scanf("%f", &small);
    printf("Enter value medium: $");
    scanf("%f", &medium);
    printf("Enter value large: $");
    scanf("%f", &large);
    printf("\nEnter amount to buy: ");
    scanf("%d", &numb);
    
    printf("\nPatty's shirt size is %c", patSize);
    printf ("\nNumber of shirts Patty is buying: ");
    scanf("%d", &numbp);

    printf("\nTommy's shirt size is %c", tomSize);
    printf ("\nNumber of shirts Tommy is buying: ");
    scanf("%d", &numbt);

    printf("\nSally's shirt size is %c", salSize);
    printf ("\nNumber of shirts Sally is buying: ");
    scanf("%d", &numbs);

    //output
    printf("Customer Size Price Qty Sub-Total       Tax     Total");
    printf("-------- ---- ----- --- --------- --------- ---------");
    printf("Patty   %-4c %5.2lf %3d %9.4lf %9.4lf %9.4lf\n");
    printf("-------- ---- ----- --- --------- --------- ---------");
    printf("%33.4lf %9.4lf %9.4lf\n\n");

    //from w02/01
    /* //subtotal rounding
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
    printf("\nSubtotal is: %8.4lf", nst);
    printf("\nTax is     : %8.4f", ntaxt);
    printf("\nTotal is   : %8.4f", ntota);
    printf("\n");
    */

    return 0;
    
}
