// Online C compiler to run C program online
#define _CRT_SECURE_NO_WARNINGS
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
    
    printf("\nPatty's shirt size is %c", patSize);
    printf ("\nNumber of shirts Patty is buying: ");
    scanf("%d", &numbp);

    printf("\nTommy's shirt size is %c", tomSize);
    printf ("\nNumber of shirts Tommy is buying: ");
    scanf("%d", &numbt);

    printf("\nSally's shirt size is %c", salSize);
    printf ("\nNumber of shirts Sally is buying: ");
    scanf("%d", &numbs);

    //patty subtotal rounding
    float ps = small * numbp * 100;
    int pns = ps +.5;
    float pst = (float)pns /100;
    
    //patty tax rounding
    float pt = pst * TAX * 100; //changes number to 1867.8398
    int ptx = pt + .5; //Rounds above number to 1868
    float ptax = (float)ptx / 100; //changes number to 18.68    
    
    //patty total rounding
    float ptt = (pst + ptax) * 100;
    int pto = ptt +.5;
    float ptot = (float)pto /100;

    //sally subtotal rounding
    float ss = medium * numbs * 100;
    int sns = ss +.5;
    float sst = (float)sns /100;
    
    //sally tax rounding
    float st = sst * TAX * 100; //changes number to 1867.8398
    int stx = st + .5; //Rounds above number to 1868
    float stax = (float)stx / 100; //changes number to 18.68    
    
    //sally total rounding
    float stt = (sst + stax) * 100;
    int sto = stt +.5;
    float stot = (float)sto /100;

    //tommy subtotal rounding
    float tts = large * numbt * 100;
    int tns = tts +.5;
    float tst = (float)tns /100;
    
    //tommy tax rounding
    float tta = tst * TAX * 100; //changes number to 1867.8398
    int ttx = tta + .5; //Rounds above number to 1868
    float ttax = (float)ttx / 100; //changes number to 18.68    
    
    //tommy total rounding
    float ttt = (tst + ttax) * 100;
    int tto = ttt +.5;
    float ttot = (float)tto /100;
    
    //calculate totals
    float subtt = pst + sst + tst;
    float taxt = ptax + stax +ttax;
    float ttoal = ptot + stot + ttot;

    //output
    printf("\nCustomer Size Price Qty Sub-Total       Tax     Total");
    printf("\n-------- ---- ----- --- --------- --------- ---------");
    printf("\nPatty    %-4c %5.2lf %3d %9.4lf %9.4lf %9.4lf",patSize,small,numbp,pst,ptax,ptot);
    printf("\nSally    %-4c %5.2lf %3d %9.4lf %9.4lf %9.4lf",salSize,medium,numbs,sst,stax,stot);
    printf("\nTommy    %-4c %5.2lf %3d %9.4lf %9.4lf %9.4lf",tomSize,large,numbt,tst,ttax,ttot);
    printf("\n-------- ---- ----- --- --------- --------- ---------");
    printf("\n%33.4lf %9.4lf %9.4lf\n\n",subtt,taxt,ttoal);

    printf("\nDaily retail sales represented by coins");
    printf("\n=======================================\n");
    printf("Sales EXCLUDING tax\n");
    printf("Coin Qty Balance\n");
    printf("-------- --- ---------\n");
    printf("%22.4lf\n",subtt);
    //calculate toonie
    //float cents = subtt*100;
    int toonies = subtt/2;
    float toont = toonies * 2;
    float tbal = subtt - toont;
    //calculate loonie
    int loonies = tbal/1;
    float loont = loonies * 1;
    float lbal = tbal - loont;
    //calculate quarters
    int quarters = lbal/.25;
    float quart = quarters * .25;
    float qbal = lbal - quart;
    //calculate dimes
    int dimes = qbal/.10;
    float dime = dimes * .10;
    float dbal = qbal - dime;
    //calculate nickels
    int nickels = dbal/.05;
    float nick = nickels * .05;
    float nbal = dbal - nick;
    //calculate pennies
    int pennies = nbal/.01;
    float pen = pennies * .01;
    float pbal = nbal - pen;
    printf("Toonies  %3d %9.4lf\n",toonies,tbal);
    printf("Loonies %3d %9.4lf\n",loonies,lbal);
    printf("Quarters %3d %9.4lf\n",quarters,qbal);
    printf("Dimes %3d %9.4lf\n",dimes,dbal);
    printf("Nickels %3d %9.4lf\n",nickels,nbal);
    printf("Pennies %3d %9.4lf\n",pennies,pbal);
    float avge = subtt/(numbp + numbs + numbt);
    printf("\nAverage cost/shirt: $%7.4lf\n",avge);

    //sales with TAX
    printf("\nSales INCLUDING tax\n");
    printf("Coin Qty Balance\n");
    printf("-------- --- ---------\n");
    printf("%22.4lf\n",ttoal);
    //calculate toonie
    //float cents = subtt*100;
    int toonies1 = ttoal/2;
    float toont1 = toonies1 * 2;
    float tbal1 = ttoal - toont1;
    //calculate loonie
    int loonies1 = tbal1/1;
    float loont1 = loonies1 * 1;
    float lbal1 = tbal1 - loont1;
    //calculate quarters
    int quarters1 = lbal1/.25;
    float quart1 = quarters1 * .25;
    float qbal1 = lbal1 - quart1;
    //calculate dimes
    int dimes1 = qbal1/.10;
    float dime1 = dimes1 * .10;
    float dbal1 = qbal1 - dime1;
    //calculate nickels
    int nickels1 = dbal1/.05;
    float nick1 = nickels1 * .05;
    float nbal1 = dbal1 - nick1;
    //calculate pennies
    int pennies1 = nbal1/.01;
    float pen1 = pennies1 * .01;
    float pbal1 = nbal1 - pen1;
    printf("Toonies  %3d %9.4lf\n",toonies1,tbal1);
    printf("Loonies %3d %9.4lf\n",loonies1,lbal1);
    printf("Quarters %3d %9.4lf\n",quarters1,qbal1);
    printf("Dimes %3d %9.4lf\n",dimes1,dbal1);
    printf("Nickels %3d %9.4lf\n",nickels1,nbal1);
    printf("Pennies %3d %9.4lf\n",pennies1,pbal1);
    float avge1 = ttoal/(numbp + numbs + numbt);
    printf("\nAverage cost/shirt: $%7.4lf\n",avge1);

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
