/*
 * multiplies three inputs
 */

public int main() {

    // Do we need two bits because of signed integers?
    private int<4> v1[10], v2[10], v3[10]; // , v4[10], v5[10], v6[10], v7[10], v8[10], v9[10], v10[10];


    smcinput(v1,1,10);
    smcinput(v2,2,10);
    smcinput(v3,3,10);
    // smcinput(v4,4,10);
    // smcinput(v5,5,10);
    // smcinput(v6,6,10);
    // smcinput(v7,7,10);
    // smcinput(v8,8,10);
    // smcinput(v9,9,10);
    // smcinput(v10,10,10);

    private int<4> s1[10];
    s1 = v1 + v2; //first line must be addition, rather than pure assignment, otherwise it segfaults in transpilation
    s1 = s1 + v3;
    // s1 = s1 + v4;
    // s1 = s1 + v5;
    // s1 = s1 + v6;
    // s1 = s1 + v7;
    // s1 = s1 + v8;
    // s1 = s1 + v9;
    // s1 = s1 + v10;

    
    private int<4> max = 0;
    for(public int i = 0; i < 10; i++) 
        if(s1[i] > max) max = s1[i];

    //TODO: Add noise!

    private int<4> b;
    if (max > 8) {
        b = 1;
    } else {
        b = 0;
    }
    
    smcoutput(b,1);
    return 0;

}
