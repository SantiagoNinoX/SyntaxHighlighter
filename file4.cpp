#include <iostream>
#include <string>
using namespace std;

int sum(int a, int b) {
    return a + b;
}

void printMessage(string msg) {
    cout << msg << endl;
}

bool check() {
    return true;
}

int main() {
    printMessage('Function_test');
    int total = sum(10, 20);
    cout << 'Sum' << total << endl;

    for (int i = 0; i < 3; i++) {
        cout << 'i_' << i << endl;
    }

    int x = 0;
    while (x < 2) {
        cout << 'x_' << x << endl;
        x++;
    }

    do {
        cout << 'Do_once' << endl;
    } while (false);

    if (check()) {
        cout << 'Check_passed' << endl;
    }

    return 0;
}
